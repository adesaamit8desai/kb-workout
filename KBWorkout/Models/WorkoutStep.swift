import Foundation

struct StepOptions: Hashable {
    var includeWarmup = true
    /// Replaces the programme's standard 60 s rest after rep-based sets.
    var restBetweenSets = 60
    var getReady = 10
}

/// A single interval in a workout, produced by flattening blocks, rounds and items.
struct WorkoutStep: Identifiable, Hashable {
    enum Kind { case getReady, work, rest }
    enum Section { case warmup, main, cooldown }

    let id: Int
    let kind: Kind
    let section: Section
    /// Timed steps count down; rep sets wait for the user to tap Done.
    let isTimed: Bool
    /// Seconds for timed steps, an estimate for rep sets.
    let duration: Int
    let exercise: Exercise?
    let side: String?
    let reps: Int?
    let target: String?
    let note: String?
    let showsCounter: Bool
    let blockName: String
    let blockIndex: Int
    let blockCount: Int
    /// Position among the main (non warm-up) blocks, for "Exercise 2 of 6".
    let mainBlockNumber: Int
    let mainBlockCount: Int
    let round: Int
    let totalRounds: Int
    let isStraightSets: Bool

    var isRepSet: Bool { kind == .work && !isTimed }

    /// "Set 2 of 4" or "Round 2 of 3"; nil for single-round blocks.
    var progressLabel: String? {
        guard totalRounds > 1 else { return nil }
        return "\(isStraightSets ? "Set" : "Round") \(round) of \(totalRounds)"
    }

    var title: String {
        switch kind {
        case .getReady: "Get Ready"
        case .rest: "Rest"
        case .work: exercise?.name ?? blockName
        }
    }

    /// Counted once per set (a left + right pair counts as one) in the main section.
    var countsAsSet: Bool { kind == .work && section == .main && side != "Right" && !isTimed }
    var countsAsInterval: Bool { kind == .work && section == .main && side != "Right" && isTimed }
}

extension Workout {
    func steps(using library: WorkoutLibrary, options: StepOptions = StepOptions()) -> [WorkoutStep] {
        var sections: [(block: WorkoutBlock, section: WorkoutStep.Section)] = blocks.map { ($0, .main) }
        if options.includeWarmup && warmup {
            sections.insert((library.warmup, .warmup), at: 0)
            sections.append((library.cooldown, .cooldown))
        }
        let mainCount = blocks.count
        var mainNumber = 0
        var steps: [WorkoutStep] = []

        for (blockIndex, entry) in sections.enumerated() {
            let block = entry.block
            if entry.section == .main { mainNumber += 1 }

            func add(_ kind: WorkoutStep.Kind, timed: Bool, duration: Int, item: WorkoutItem?, side: String?, round: Int) {
                guard duration > 0 || !timed else { return }
                steps.append(WorkoutStep(
                    id: steps.count, kind: kind, section: entry.section, isTimed: timed, duration: duration,
                    exercise: library.exercise(item?.exercise), side: side, reps: item?.reps, target: item?.target,
                    note: item?.note, showsCounter: item?.counter == true, blockName: block.name,
                    blockIndex: blockIndex, blockCount: sections.count, mainBlockNumber: mainNumber,
                    mainBlockCount: mainCount, round: round, totalRounds: block.rounds,
                    isStraightSets: block.isStraightSets))
            }

            guard block.rounds > 0 else { continue }
            for round in 1...block.rounds {
                for (itemIndex, item) in block.items.enumerated() {
                    let duration = item.work ?? estimatedRepSeconds(item, library: library)
                    let sides: [String?] = item.perSide == true ? ["Left", "Right"] : [nil]
                    for side in sides {
                        add(.work, timed: item.isTimed, duration: duration, item: item, side: side, round: round)
                    }
                    var rest = item.rest
                    if !item.isTimed && rest == 60 { rest = options.restBetweenSets }
                    if itemIndex == block.items.count - 1, round < block.rounds, let between = block.restBetweenRounds {
                        rest = between
                    }
                    add(.rest, timed: true, duration: rest, item: nil, side: nil, round: round)
                }
            }
        }
        while steps.last?.kind == .rest { steps.removeLast() }

        if options.getReady > 0, let first = steps.first {
            let ready = WorkoutStep(
                id: -1, kind: .getReady, section: first.section, isTimed: true, duration: options.getReady,
                exercise: first.exercise, side: nil, reps: nil, target: nil, note: nil, showsCounter: false,
                blockName: first.blockName, blockIndex: first.blockIndex, blockCount: first.blockCount,
                mainBlockNumber: first.mainBlockNumber, mainBlockCount: first.mainBlockCount,
                round: 1, totalRounds: first.totalRounds, isStraightSets: first.isStraightSets)
            steps.insert(ready, at: 0)
        }
        // Re-number so ids are sequential and unique.
        return steps.enumerated().map { index, step in step.withID(index) }
    }

    func estimatedSeconds(using library: WorkoutLibrary, options: StepOptions = StepOptions()) -> Int {
        var opts = options
        opts.getReady = 0
        return steps(using: library, options: opts).reduce(0) { $0 + $1.duration }
    }

    private func estimatedRepSeconds(_ item: WorkoutItem, library: WorkoutLibrary) -> Int {
        guard let reps = item.reps else { return 40 }
        return (library.exercise(item.exercise)?.secondsPerRep ?? 3) * reps + 5
    }
}

private extension WorkoutStep {
    func withID(_ newID: Int) -> WorkoutStep {
        WorkoutStep(id: newID, kind: kind, section: section, isTimed: isTimed, duration: duration, exercise: exercise,
                    side: side, reps: reps, target: target, note: note, showsCounter: showsCounter,
                    blockName: blockName, blockIndex: blockIndex, blockCount: blockCount,
                    mainBlockNumber: mainBlockNumber, mainBlockCount: mainBlockCount, round: round,
                    totalRounds: totalRounds, isStraightSets: isStraightSets)
    }
}
