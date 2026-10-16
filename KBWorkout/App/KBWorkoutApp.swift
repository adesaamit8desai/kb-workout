import SwiftUI
import SwiftData

@main
struct KBWorkoutApp: App {
    @State private var library = WorkoutLibrary()
    private let container = KBWorkoutApp.makeContainer()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(library)
                .preferredColorScheme(.dark)
                .tint(Theme.volt)
        }
        .modelContainer(container)
    }

    /// UI tests launch with `-uiTesting` (throwaway in-memory history) and optionally `-seedHistory`.
    @MainActor
    private static func makeContainer() -> ModelContainer {
        let arguments = ProcessInfo.processInfo.arguments
        let inMemory = arguments.contains("-uiTesting")
        do {
            let container = try ModelContainer(for: CompletedWorkout.self,
                                               configurations: ModelConfiguration(isStoredInMemoryOnly: inMemory))
            if inMemory && arguments.contains("-seedHistory") {
                SampleHistory.insert(into: container.mainContext)
            }
            return container
        } catch {
            fatalError("Couldn't open workout history: \(error)")
        }
    }
}

struct RootView: View {
    var body: some View {
        TabView {
            BrowseView()
                .tabItem { Label("Workouts", systemImage: "figure.strengthtraining.functional") }
            HistoryView()
                .tabItem { Label("History", systemImage: "chart.bar.fill") }
        }
    }
}

/// Example history used only by UI tests and screenshots.
enum SampleHistory {
    static func insert(into context: ModelContext) {
        let calendar = Calendar.current
        let entries: [(daysAgo: Int, id: String, title: String, theme: String, minutes: Double, effort: Int)] = [
            (1, "session-c", "Session C", "violet", 34, 4),
            (3, "swing-burn", "Swing Burn", "volt", 27, 4),
            (5, "session-b", "Session B", "ocean", 33, 3),
            (8, "session-a", "Session A", "ember", 35, 3),
            (10, "easy-day", "Easy Day Flow", "steel", 24, 1),
            (12, "emom-20", "EMOM 20", "ocean", 28, 4),
            (16, "session-c", "Session C", "violet", 33, 3),
            (19, "session-b", "Session B", "ocean", 31, 3),
            (24, "session-a", "Session A", "ember", 36, 2),
        ]
        for entry in entries {
            let date = calendar.date(byAdding: .day, value: -entry.daysAgo, to: .now) ?? .now
            context.insert(CompletedWorkout(
                workoutID: entry.id, title: entry.title, theme: entry.theme, date: date,
                duration: entry.minutes * 60, completed: true, bellWeightKg: 16, effort: entry.effort,
                notes: entry.daysAgo == 1 ? "Press felt strong. Try 20 kg deadlifts next time." : "",
                setsDone: 16, setsTotal: 16))
        }
    }
}
