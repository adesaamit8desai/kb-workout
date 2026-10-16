import SwiftUI
import SwiftData

struct SummaryView: View {
    @Environment(\.modelContext) private var context
    @Environment(WorkoutLibrary.self) private var library
    @AppStorage("bellWeightKg") private var bellWeight = 16.0
    let session: WorkoutSession
    let onDone: () -> Void

    @State private var effort = 3
    @State private var notes = ""

    private var workout: Workout { session.workout }

    private var nextTime: Workout? {
        guard workout.category == .programme else { return nil }
        let programme = library.workouts(in: .programme)
        guard let index = programme.firstIndex(of: workout) else { return nil }
        return programme[(index + 1) % programme.count]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                    tile("Total time") {
                        Text(session.elapsed.clock(.down)).foregroundStyle(Theme.elapsed)
                    }
                    if session.setsTotal > 0 {
                        tile("Sets") { Text("\(session.setsDone)/\(session.setsTotal)").foregroundStyle(Theme.volt) }
                    }
                    if session.totalCount > 0 {
                        tile("Rounds") { Text("\(session.totalCount)").foregroundStyle(Theme.volt) }
                    } else if session.intervalsTotal > 0 {
                        tile("Intervals") {
                            Text("\(session.intervalsDone)/\(session.intervalsTotal)").foregroundStyle(Theme.volt)
                        }
                    }
                    tile("Bell") {
                        HStack {
                            Text("\(Int(bellWeight)) kg")
                            Spacer()
                            stepperButton("minus", label: "Lighter") { bellWeight = max(4, bellWeight - 2) }
                            stepperButton("plus", label: "Heavier") { bellWeight = min(48, bellWeight + 2) }
                        }
                    }
                }
                effortPicker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes").font(.system(size: 17, weight: .bold))
                    TextField("How did it feel? Anything to change next time?", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                        .padding(12)
                        .background(Theme.card, in: RoundedRectangle(cornerRadius: 14))
                }
                Button("Save to History") { save() }
                    .buttonStyle(PillButtonStyle())
                    .padding(.top, 8)
                Button("Discard workout", role: .destructive) { onDone() }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.danger)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 32)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: session.endedEarly ? "flag.checkered" : "checkmark")
                .font(.system(size: 40, weight: .heavy))
                .foregroundStyle(Theme.onVolt)
                .frame(width: 84, height: 84)
                .background(Theme.volt, in: Circle())
            Text(session.endedEarly ? "\(workout.title) ended" : "\(workout.title) complete")
                .font(.system(size: 30, weight: .heavy))
                .multilineTextAlignment(.center)
            Text([Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide)),
                  nextTime.map { "Next time: \($0.title)" }].compactMap { $0 }.joined(separator: " · "))
                .font(.system(size: 15))
                .foregroundStyle(Theme.secondary)
        }
    }

    private var effortPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How hard was it?").font(.system(size: 17, weight: .bold))
            HStack(spacing: 6) {
                ForEach(1...5, id: \.self) { value in
                    Button(Effort.label(value)) { effort = value }
                        .font(.system(size: 14, weight: .bold))
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .foregroundStyle(effort == value ? Color.black : Color.white)
                        .background(effort == value ? Theme.effortColor(value) : Theme.card,
                                    in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func tile<Value: View>(_ label: String, @ViewBuilder value: () -> Value) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Eyebrow(text: label)
            value().font(Theme.numerals(30, .black)).monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 16))
    }

    private func stepperButton(_ symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(Theme.raised, in: Circle())
        }
        .accessibilityLabel(label)
    }

    private func save() {
        context.insert(CompletedWorkout(
            workoutID: workout.id, title: workout.title, theme: workout.theme, date: session.startDate,
            duration: session.elapsed, completed: !session.endedEarly, bellWeightKg: bellWeight, effort: effort,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            setsDone: session.setsDone, setsTotal: session.setsTotal))
        onDone()
    }
}
