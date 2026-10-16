import SwiftUI
import SwiftData

@main
struct KBWorkoutApp: App {
    @State private var library = WorkoutLibrary()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(library)
                .preferredColorScheme(.dark)
                .tint(Theme.volt)
        }
        .modelContainer(for: CompletedWorkout.self)
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
