import SwiftUI

struct PlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("voiceEnabled") private var voiceEnabled = true
    @AppStorage("bellWeightKg") private var bellWeight = 16.0
    @State private var session: WorkoutSession
    @State private var confirmingEnd = false

    init(workout: Workout, steps: [WorkoutStep]) {
        _session = State(initialValue: WorkoutSession(workout: workout, steps: steps))
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if session.isFinished {
                SummaryView(session: session) { dismiss() }
            } else {
                active
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            session.voiceEnabled = voiceEnabled
            session.start()
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            session.stop()
        }
    }

    private var step: WorkoutStep { session.current }

    private var accent: Color {
        switch step.kind {
        case .getReady: Theme.elapsed
        case .rest: Theme.rest
        case .work: Theme.volt
        }
    }

    // MARK: Layout

    private var active: some View {
        VStack(spacing: 16) {
            topBar
            timeRow
            SegmentBar(count: step.blockCount, current: step.blockIndex, progress: session.blockProgress)
            Spacer(minLength: 0)
            if step.isRepSet {
                repSet
            } else if step.kind == .rest {
                rest
            } else {
                interval
            }
            Spacer(minLength: 0)
            bottomControls
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .animation(.easeInOut(duration: 0.25), value: session.index)
        .confirmationDialog("End this workout?", isPresented: $confirmingEnd, titleVisibility: .visible) {
            Button("Finish and Save") { session.end() }
            Button("Discard Workout", role: .destructive) {
                session.stop()
                dismiss()
            }
            Button("Keep Going", role: .cancel) {}
        }
    }

    private var topBar: some View {
        HStack {
            Button("End") { confirmingEnd = true }
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Theme.danger)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Theme.card, in: Capsule())
            Spacer()
            Text(session.workout.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.secondary)
            Spacer()
            Button {
                voiceEnabled.toggle()
                session.voiceEnabled = voiceEnabled
            } label: {
                Image(systemName: voiceEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Theme.card, in: Circle())
            }
            .accessibilityLabel(voiceEnabled ? "Turn voice coaching off" : "Turn voice coaching on")
        }
    }

    private var timeRow: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.elapsed.clock(.down))
                    .font(Theme.numerals(46, .bold))
                    .monospacedDigit()
                    .foregroundStyle(Theme.elapsed)
                Eyebrow(text: "Elapsed")
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(remainingText)
                    .font(Theme.numerals(22, .bold))
                    .monospacedDigit()
                Eyebrow(text: "Left")
            }
        }
    }

    private var remainingText: String {
        let left = session.totalRemaining
        return left >= 120 ? "~\(Int((left / 60).rounded(.up))) min" : left.clock()
    }

    private var eyebrowText: String {
        let place = switch step.section {
        case .warmup: "Warm-up"
        case .cooldown: "Cool-down"
        case .main: step.isStraightSets
            ? "Exercise \(step.mainBlockNumber) of \(step.mainBlockCount)"
            : step.blockName
        }
        return [place, step.progressLabel].compactMap { $0 }.joined(separator: " · ")
    }

    // MARK: Rep set (tap Done)

    private var repSet: some View {
        VStack(spacing: 12) {
            Eyebrow(text: eyebrowText, color: Theme.volt)
            Text(step.title)
                .font(.system(size: 34, weight: .heavy))
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(.system(size: 15))
                .foregroundStyle(Theme.secondary)
            if let reps = step.reps {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("\(reps)")
                        .font(Theme.numerals(112, .black))
                        .foregroundStyle(Theme.volt)
                    Text("reps").font(.system(size: 26, weight: .heavy))
                }
            } else if let target = step.target {
                Text(target)
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundStyle(Theme.volt)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 12)
            }
            if step.isStraightSets && step.totalRounds > 1 && step.totalRounds <= 10 {
                HStack(spacing: 8) {
                    ForEach(1...step.totalRounds, id: \.self) { set in
                        Capsule()
                            .fill(set < step.round ? Theme.volt : set == step.round ? Theme.volt.opacity(0.55) : Theme.raised)
                            .frame(width: 34, height: 8)
                    }
                }
            }
            if let note = step.note {
                NoteCard(text: note)
                    .padding(.top, 6)
            }
        }
    }

    private var subtitle: String {
        var parts: [String] = []
        if let side = step.side { parts.append("\(side) side") }
        parts.append(session.workout.bells == 2 && step.section == .main ? "2 bells" : "\(Int(bellWeight)) kg bell")
        return parts.joined(separator: " · ")
    }

    // MARK: Rest

    private var rest: some View {
        VStack(spacing: 18) {
            ZStack {
                ActivityRing(progress: 1 - session.stepProgress, color: Theme.rest, lineWidth: 22)
                VStack(spacing: 2) {
                    Eyebrow(text: "Rest", color: Theme.rest)
                    Text(countdownText)
                        .font(Theme.numerals(96, .black))
                        .monospacedDigit()
                    if session.stepRemaining < 60 {
                        Text("seconds").font(.system(size: 14)).foregroundStyle(Theme.secondary)
                    }
                }
            }
            .frame(width: 260, height: 260)
            HStack(spacing: 12) {
                Button("+15 sec") { session.addRest(15) }
                    .buttonStyle(ChipButtonStyle(color: Theme.rest))
                Button("Skip rest") { session.skipForward() }
                    .buttonStyle(ChipButtonStyle(color: Theme.rest))
            }
            if let next = session.nextWorkStep {
                UpNextCard(step: next)
            }
        }
    }

    // MARK: Timed interval / get ready

    private var interval: some View {
        VStack(spacing: 14) {
            Eyebrow(text: step.kind == .getReady ? "First up" : eyebrowText, color: accent)
            ZStack {
                ActivityRing(progress: 1 - session.stepProgress, color: accent, lineWidth: 24)
                VStack(spacing: 2) {
                    Eyebrow(text: step.kind == .getReady ? "Get ready" : "Work", color: accent)
                    Text(countdownText)
                        .font(Theme.numerals(session.stepRemaining < 60 ? 96 : 76, .black))
                        .monospacedDigit()
                    if let side = step.side {
                        Text("\(side.uppercased()) SIDE")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(accent)
                    }
                }
            }
            .frame(width: 260, height: 260)
            Text(step.kind == .getReady ? (step.exercise?.name ?? step.blockName) : step.title)
                .font(.system(size: 28, weight: .heavy))
                .multilineTextAlignment(.center)
            if let target = step.target, step.kind == .work {
                Text(target)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(accent)
                    .multilineTextAlignment(.center)
            }
            if let note = step.note {
                Text(note)
                    .font(.system(size: 15))
                    .foregroundStyle(Theme.secondary)
                    .multilineTextAlignment(.center)
            }
            if step.showsCounter {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 0) {
                        Eyebrow(text: "Rounds")
                        Text("\(session.currentCount)").font(Theme.numerals(34, .black))
                    }
                    Button {
                        session.countRound()
                    } label: {
                        Label("Round done", systemImage: "plus")
                    }
                    .buttonStyle(PillButtonStyle(height: 52))
                }
                .padding(14)
                .background(Theme.card, in: RoundedRectangle(cornerRadius: 18))
            } else if step.kind == .work, let next = session.nextStep {
                if next.kind == .rest {
                    UpNextRow(title: session.nextWorkStep.map { "Rest, then \($0.title)" } ?? "Rest",
                              trailing: "\(next.duration)s", color: Theme.rest)
                } else {
                    UpNextRow(title: next.title + (next.side.map { " · \($0)" } ?? ""), trailing: nil, color: Theme.volt)
                }
            }
        }
    }

    private var countdownText: String {
        session.stepRemaining < 60 ? "\(Int(session.stepRemaining.rounded(.up)))" : session.stepRemaining.clock()
    }

    // MARK: Controls

    @ViewBuilder
    private var bottomControls: some View {
        if step.isRepSet {
            VStack(spacing: 10) {
                Text("This set: \(session.stepElapsed.clock(.down))")
                    .font(.system(size: 14))
                    .monospacedDigit()
                    .foregroundStyle(Theme.secondary)
                Button {
                    session.completeSet()
                } label: {
                    Label(session.nextStep?.kind == .rest ? "Done · Start Rest" : "Done",
                          systemImage: "checkmark")
                        .font(.system(size: 19, weight: .heavy))
                }
                .buttonStyle(PillButtonStyle(height: 64))
                HStack {
                    textControl("‹ Previous") { session.skipBack() }
                    Spacer()
                    textControl(session.isPaused ? "Resume" : "Pause") { session.togglePause() }
                    Spacer()
                    textControl("Skip ›") { session.skipForward() }
                }
            }
        } else {
            HStack(spacing: 44) {
                roundControl("backward.end.fill", label: "Previous") { session.skipBack() }
                Button {
                    session.togglePause()
                } label: {
                    Image(systemName: session.isPaused ? "play.fill" : "pause.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(step.kind == .rest ? Theme.onRest : Theme.onVolt)
                        .frame(width: 76, height: 76)
                        .background(accent, in: Circle())
                }
                .accessibilityLabel(session.isPaused ? "Resume" : "Pause")
                roundControl("forward.end.fill", label: "Skip") { session.skipForward() }
            }
        }
    }

    private func roundControl(_ symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 20))
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(Theme.card, in: Circle())
        }
        .accessibilityLabel(label)
    }

    private func textControl(_ title: String, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(Theme.secondary)
            .padding(8)
    }
}

private struct NoteCard: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 15))
            .foregroundStyle(Color(hex: 0xE5E5EA))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 14))
    }
}

private struct UpNextCard: View {
    let step: WorkoutStep

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Eyebrow(text: ["Up next", step.progressLabel, step.side.map { "\($0) side" }]
                .compactMap { $0 }.joined(separator: " · "))
            HStack(alignment: .firstTextBaseline) {
                Text(step.title).font(.system(size: 20, weight: .heavy))
                Spacer()
                if let reps = step.reps {
                    Text("\(reps) reps").font(Theme.numerals(20, .black)).foregroundStyle(Theme.volt)
                } else if step.isTimed {
                    Text("\(step.duration)s").font(Theme.numerals(20, .black)).foregroundStyle(Theme.volt)
                }
            }
            if let detail = step.note ?? step.target {
                Text(detail).font(.system(size: 14)).foregroundStyle(Theme.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 18))
    }
}

private struct UpNextRow: View {
    let title: String
    let trailing: String?
    let color: Color

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Eyebrow(text: "Up next")
                Text(title).font(.system(size: 17, weight: .bold)).lineLimit(1)
            }
            Spacer()
            if let trailing {
                Text(trailing).font(Theme.numerals(20, .black)).foregroundStyle(color)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 18))
    }
}

private struct ChipButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(color)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(Theme.card, in: Capsule())
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
