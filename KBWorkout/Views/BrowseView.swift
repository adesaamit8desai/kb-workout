import SwiftUI
import SwiftData

struct BrowseView: View {
    @Environment(WorkoutLibrary.self) private var library
    @Query(sort: \CompletedWorkout.date, order: .reverse) private var history: [CompletedWorkout]
    @State private var showingSettings = false
    @AppStorage("includeWarmup") private var includeWarmup = true
    @AppStorage("restBetweenSets") private var restBetweenSets = 60

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    WeekSummaryCard(history: history)
                        .padding(.horizontal, 20)
                    if let next = library.nextProgrammeSession(history: history) {
                        upNext(next)
                    }
                    Shelf(title: "Something Different", workouts: library.freshPicks(history: history))
                    ForEach(WorkoutCategory.allCases) { category in
                        let workouts = library.workouts(in: category)
                        if !workouts.isEmpty {
                            Shelf(title: category.title, workouts: workouts)
                        }
                    }
                }
                .padding(.vertical, 12)
            }
            .background(Color.black)
            .statusBarBackdrop()
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Workout.self) { WorkoutDetailView(workout: $0) }
            .sheet(isPresented: $showingSettings) { SettingsView() }
        }
    }

    private var header: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text(Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide)).uppercased())
                    .font(.system(size: 13, weight: .semibold))
                    .tracking(0.8)
                    .foregroundStyle(Theme.secondary)
                Text("Workouts")
                    .font(.system(size: 34, weight: .heavy))
            }
            Spacer()
            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 17))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Theme.card, in: Circle())
            }
            .accessibilityLabel("Settings")
        }
        .padding(.horizontal, 20)
    }

    private func upNext(_ workout: Workout) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Up Next")
                .font(.system(size: 22, weight: .heavy))
            NavigationLink(value: workout) {
                ZStack(alignment: .bottomLeading) {
                    WorkoutArt(workout: workout, letterSize: 140, symbolSize: 120)
                    VStack(alignment: .leading, spacing: 6) {
                        Eyebrow(text: "\(workout.category.title) · ~\(library.minutes(workout)) min",
                                color: .white.opacity(0.85))
                        Text(workout.title)
                            .font(.system(size: 32, weight: .heavy))
                        Text(workout.subtitle)
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.85))
                            .multilineTextAlignment(.leading)
                        Text("Start")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Theme.tile(workout.theme))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(.white, in: Capsule())
                            .padding(.top, 6)
                    }
                    .foregroundStyle(.white)
                    .padding(18)
                }
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 22))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("upNext")
        }
        .padding(.horizontal, 20)
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("weeklyGoalMinutes") private var goal = 90
    @AppStorage("voiceEnabled") private var voiceEnabled = true
    @AppStorage("restBetweenSets") private var restBetweenSets = 60
    @AppStorage("bellWeightKg") private var bellWeight = 16.0

    var body: some View {
        NavigationStack {
            Form {
                Section("Goal") {
                    Stepper("Weekly goal: \(goal) min", value: $goal, in: 30...300, step: 15)
                }
                Section("Workouts") {
                    Toggle("Voice coaching", isOn: $voiceEnabled)
                    Picker("Rest between sets", selection: $restBetweenSets) {
                        ForEach([45, 60, 75, 90], id: \.self) { Text("\($0) sec").tag($0) }
                    }
                    Stepper("Usual bell: \(Int(bellWeight)) kg", value: $bellWeight, in: 4...48, step: 2)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
    }
}
