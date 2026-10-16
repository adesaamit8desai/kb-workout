import SwiftUI

struct WorkoutDetailView: View {
    @Environment(WorkoutLibrary.self) private var library
    let workout: Workout

    @AppStorage("includeWarmup") private var includeWarmup = true
    @AppStorage("restBetweenSets") private var restBetweenSets = 60
    @AppStorage("bellWeightKg") private var bellWeight = 16.0
    @State private var playing: PlayerLaunch?
    @State private var selectedExercise: Exercise?

    private var options: StepOptions {
        StepOptions(includeWarmup: includeWarmup && workout.warmup, restBetweenSets: restBetweenSets)
    }

    private var setCount: Int {
        workout.blocks.reduce(0) { total, block in
            total + block.items.filter { !$0.isTimed }.count * block.rounds
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                hero
                VStack(alignment: .leading, spacing: 18) {
                    stats
                    optionsCard
                    Button("Start \(workout.title)") {
                        playing = PlayerLaunch(steps: workout.steps(using: library, options: options))
                    }
                    .buttonStyle(PillButtonStyle())
                    .accessibilityIdentifier("startWorkout")
                    Text("Exercises")
                        .font(.system(size: 20, weight: .heavy))
                        .padding(.top, 6)
                    VStack(spacing: 0) {
                        ForEach(Array(workout.blocks.enumerated()), id: \.offset) { index, block in
                            if index > 0 { Divider().overlay(Theme.raised).padding(.leading, 58) }
                            BlockRow(number: index + 1, block: block, restBetweenSets: restBetweenSets) {
                                selectedExercise = $0
                            }
                        }
                    }
                    .background(Theme.card, in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 32)
            }
        }
        .background(Color.black)
        .ignoresSafeArea(edges: .top)
        .toolbar(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $playing) { launch in
            PlayerView(workout: workout, steps: launch.steps)
        }
        .sheet(item: $selectedExercise) { exercise in
            ExerciseSheet(exercise: exercise)
                .presentationDetents([.medium, .large])
        }
    }

    private var hero: some View {
        WorkoutArt(workout: workout, letterSize: 150, symbolSize: 120)
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    Eyebrow(text: "\(workout.category.title) · \(workout.focus)", color: .white.opacity(0.85))
                    Text(workout.title)
                        .font(.system(size: 36, weight: .heavy))
                    Text(workout.description)
                        .font(.system(size: 15))
                        .foregroundStyle(.white.opacity(0.85))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.bottom, 22)
            }
            .frame(height: 320)
    }

    private var stats: some View {
        HStack(alignment: .top, spacing: 8) {
            stat("~\(library.minutes(workout, options: options))", "Minutes")
            if setCount > 0 {
                stat("\(setCount)", "Sets")
            } else {
                stat("\(workout.blocks.count)", workout.blocks.count == 1 ? "Block" : "Blocks")
            }
            stat(workout.bells == 2 ? "2 bells" : "\(Int(bellWeight)) kg", workout.bells == 2 ? "Equipment" : "Your bell")
        }
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value).font(Theme.numerals(22, .black))
            Eyebrow(text: label)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var optionsCard: some View {
        if workout.warmup || workout.hasRepSets {
            VStack(spacing: 0) {
                if workout.warmup {
                    Toggle("Include warm-up & cool-down", isOn: $includeWarmup)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                }
                if workout.warmup && workout.hasRepSets {
                    Divider().overlay(Theme.raised).padding(.leading, 16)
                }
                if workout.hasRepSets {
                    HStack {
                        Text("Rest between sets")
                        Spacer()
                        Picker("Rest between sets", selection: $restBetweenSets) {
                            ForEach([45, 60, 75, 90], id: \.self) { Text("\($0) sec").tag($0) }
                        }
                        .labelsHidden()
                    }
                    .padding(.leading, 16)
                    .padding(.trailing, 4)
                    .padding(.vertical, 4)
                }
            }
            .tint(Theme.volt)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 14))
        }
    }
}

/// Wrapper so the full-screen player gets a fresh set of steps each time.
struct PlayerLaunch: Identifiable {
    let id = UUID()
    let steps: [WorkoutStep]
}

private struct BlockRow: View {
    @Environment(WorkoutLibrary.self) private var library
    let number: Int
    let block: WorkoutBlock
    let restBetweenSets: Int
    let onSelect: (Exercise) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text("\(number)")
                .font(Theme.numerals(14, .black))
                .foregroundStyle(Theme.volt)
                .frame(width: 28, height: 28)
                .background(Theme.volt.opacity(0.15), in: Circle())
            VStack(alignment: .leading, spacing: 6) {
                if block.isStraightSets, let item = block.items.first, let exercise = library.exercise(item.exercise) {
                    Button { onSelect(exercise) } label: {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(exercise.name).font(.system(size: 16, weight: .bold))
                            Text("\(block.rounds) sets × \(dose(item)) · \(rest(item))s rest")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Theme.volt)
                            if let note = item.note {
                                Text(note).font(.system(size: 13)).foregroundStyle(Theme.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                } else {
                    Text(block.name).font(.system(size: 16, weight: .bold))
                    if block.rounds > 1 {
                        Text("\(block.rounds) rounds")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.volt)
                    }
                    ForEach(Array(block.items.enumerated()), id: \.offset) { _, item in
                        if let exercise = library.exercise(item.exercise) {
                            Button { onSelect(exercise) } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(exercise.name) — \(dose(item))")
                                        .font(.system(size: 14))
                                    if let note = item.note {
                                        Text(note).font(.system(size: 13)).foregroundStyle(Theme.secondary)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private func rest(_ item: WorkoutItem) -> Int {
        item.rest == 60 && !item.isTimed ? restBetweenSets : item.rest
    }

    private func dose(_ item: WorkoutItem) -> String {
        var text: String
        if let work = item.work {
            text = work >= 60 && work % 60 == 0 ? "\(work / 60) min" : "\(work)s"
            if item.perSide == true { text += " each side" }
            if let target = item.target { text += " · \(target)" }
        } else if let reps = item.reps {
            text = item.target ?? "\(reps) reps"
            if item.perSide == true && item.target == nil { text += " per side" }
        } else {
            text = item.target ?? "Max reps"
            if item.perSide == true { text += " per side" }
        }
        return text
    }
}

struct ExerciseSheet: View {
    let exercise: Exercise

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 14) {
                        Image(systemName: exercise.symbol)
                            .font(.system(size: 28))
                            .foregroundStyle(Theme.volt)
                            .frame(width: 56, height: 56)
                            .background(Theme.volt.opacity(0.15), in: Circle())
                        Text(exercise.summary)
                    }
                }
                Section("Coaching cues") {
                    ForEach(exercise.cues, id: \.self) { cue in
                        Label(cue, systemImage: "checkmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .navigationTitle(exercise.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
