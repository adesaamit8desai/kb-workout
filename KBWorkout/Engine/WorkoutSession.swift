import Foundation
import Observation

/// Drives a workout: the current step, timers, pause state and voice cues.
/// Timed steps use wall-clock end dates, so they stay accurate if ticks are delayed.
@MainActor
@Observable
final class WorkoutSession {
    let workout: Workout
    let steps: [WorkoutStep]
    let startDate = Date()

    private(set) var index = 0
    /// Countdown for timed steps.
    private(set) var stepRemaining: TimeInterval
    /// Length of the current timed step, including any rest you added.
    private(set) var stepLength: TimeInterval
    /// Time spent in the current step (counts up during rep sets).
    private(set) var stepElapsed: TimeInterval = 0
    private(set) var elapsed: TimeInterval = 0
    private(set) var isPaused = false
    private(set) var isFinished = false
    private(set) var endedEarly = false
    private(set) var hasStarted = false
    private(set) var completedStepIDs: Set<Int> = []
    /// AMRAP rounds tapped, keyed by step id.
    private(set) var counts: [Int: Int] = [:]
    var voiceEnabled = true {
        didSet { coach.voiceEnabled = voiceEnabled }
    }

    @ObservationIgnored private let coach = CueCoach()
    @ObservationIgnored private var stepEndDate: Date?
    @ObservationIgnored private var lastTick = Date()
    @ObservationIgnored private var lastWholeSecond = 0
    @ObservationIgnored private var timer: Timer?

    init(workout: Workout, steps: [WorkoutStep]) {
        self.workout = workout
        self.steps = steps
        let first = TimeInterval(steps.first?.duration ?? 0)
        stepRemaining = first
        stepLength = first
    }

    // MARK: Derived state

    var current: WorkoutStep { steps[index] }

    var nextStep: WorkoutStep? { index + 1 < steps.count ? steps[index + 1] : nil }

    var nextWorkStep: WorkoutStep? { steps[(index + 1)...].first { $0.kind == .work } }

    var stepProgress: Double {
        guard current.isTimed, stepLength > 0 else { return 0 }
        return 1 - stepRemaining / stepLength
    }

    var totalRemaining: TimeInterval {
        let now = current.isTimed ? stepRemaining : max(Double(current.duration) - stepElapsed, 0)
        return now + Double(steps[(index + 1)...].reduce(0) { $0 + $1.duration })
    }

    /// Fraction of the current block's steps that are behind us.
    var blockProgress: Double {
        let inBlock = steps.filter { $0.blockIndex == current.blockIndex }
        guard let first = inBlock.first, !inBlock.isEmpty else { return 0 }
        return Double(index - first.id) / Double(inBlock.count)
    }

    var currentCount: Int { counts[current.id] ?? 0 }
    var totalCount: Int { counts.values.reduce(0, +) }

    var setsTotal: Int { steps.filter(\.countsAsSet).count }
    var setsDone: Int { steps.filter { $0.countsAsSet && completedStepIDs.contains($0.id) }.count }
    var intervalsTotal: Int { steps.filter(\.countsAsInterval).count }
    var intervalsDone: Int { steps.filter { $0.countsAsInterval && completedStepIDs.contains($0.id) }.count }

    // MARK: Controls

    func start() {
        guard !hasStarted, !steps.isEmpty else { return }
        hasStarted = true
        lastTick = .now
        begin(at: 0)
        let timer = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    /// Finishes a rep-based set and moves on (usually to rest).
    func completeSet() {
        guard !isFinished else { return }
        completedStepIDs.insert(current.id)
        advance()
    }

    func togglePause() {
        guard hasStarted, !isFinished else { return }
        if isPaused {
            lastTick = .now
            if current.isTimed { stepEndDate = .now.addingTimeInterval(stepRemaining) }
            isPaused = false
            coach.say("Resume")
        } else {
            tick()
            stepEndDate = nil
            isPaused = true
            coach.say("Paused")
        }
    }

    func skipForward() {
        guard !isFinished else { return }
        advance()
    }

    func skipBack() {
        guard !isFinished else { return }
        // Restart the current step, or go back one if it only just started.
        begin(at: stepElapsed > 3 || index == 0 ? index : index - 1)
    }

    func addRest(_ seconds: TimeInterval) {
        guard current.kind == .rest, !isFinished else { return }
        stepLength += seconds
        stepRemaining += seconds
        stepEndDate = stepEndDate?.addingTimeInterval(seconds)
    }

    func countRound() {
        counts[current.id, default: 0] += 1
        coach.countdownTick()
    }

    func end() { finish(early: true) }

    /// Stops the timer without announcing anything (used when discarding).
    func stop() {
        timer?.invalidate()
        timer = nil
        coach.silence()
    }

    // MARK: Engine

    private func advance() {
        if index + 1 < steps.count { begin(at: index + 1) } else { finish(early: false) }
    }

    private func begin(at newIndex: Int) {
        index = newIndex
        stepElapsed = 0
        stepLength = TimeInterval(current.duration)
        stepRemaining = stepLength
        lastWholeSecond = current.duration
        stepEndDate = current.isTimed && !isPaused ? .now.addingTimeInterval(stepLength) : nil
        announce()
    }

    private func tick() {
        guard hasStarted, !isPaused, !isFinished else { return }
        let now = Date()
        let delta = now.timeIntervalSince(lastTick)
        lastTick = now
        elapsed += delta
        stepElapsed += delta

        guard current.isTimed, let end = stepEndDate else { return }
        var remaining = end.timeIntervalSince(now)
        // Catch up if several intervals passed (e.g. the phone was locked).
        while remaining <= 0 {
            completedStepIDs.insert(current.id)
            guard index + 1 < steps.count else {
                stepRemaining = 0
                finish(early: false)
                return
            }
            let overshoot = -remaining
            begin(at: index + 1)
            guard current.isTimed else {
                stepElapsed = overshoot
                return
            }
            remaining = stepLength - overshoot
            stepEndDate = now.addingTimeInterval(remaining)
        }
        stepRemaining = remaining

        let whole = Int(remaining.rounded(.up))
        guard whole != lastWholeSecond else { return }
        lastWholeSecond = whole
        if (1...3).contains(whole) {
            coach.countdownTick()
            coach.say("\(whole)")
        } else if current.kind == .work, current.duration >= 120, whole % 60 == 0 {
            coach.say(whole == 60 ? "1 minute left" : "\(whole / 60) minutes left")
        } else if current.kind == .work, whole == 10, (30..<120).contains(current.duration) {
            coach.say("10 seconds")
        }
    }

    private func announce() {
        coach.stepChanged()
        let step = current
        switch step.kind {
        case .getReady:
            coach.say("Get ready. First up, \(step.exercise?.name ?? step.blockName).")
        case .work:
            if step.side == "Right" {
                coach.say("Switch sides. Right side.")
                return
            }
            var parts = [step.title + (step.side.map { ", \($0.lowercased()) side" } ?? "")]
            if let label = step.progressLabel { parts.append(label) }
            if let reps = step.reps {
                parts.append("\(reps) reps")
            } else if let target = step.target {
                parts.append(target)
            } else if step.isTimed {
                parts.append(step.duration >= 60 && step.duration % 60 == 0
                             ? "\(step.duration / 60) minutes" : "\(step.duration) seconds")
            }
            coach.say(parts.joined(separator: ". "))
        case .rest:
            var line = "Rest \(step.duration) seconds."
            if let next = nextWorkStep { line += " Next up, \(next.title)." }
            coach.say(line)
        }
    }

    private func finish(early: Bool) {
        guard !isFinished else { return }
        isFinished = true
        endedEarly = early
        timer?.invalidate()
        timer = nil
        coach.stepChanged()
        coach.say(early ? "Workout ended." : "Workout complete. Great job!")
    }
}
