import XCTest
@testable import KBWorkout

final class LibraryTests: XCTestCase {
    let library = WorkoutLibrary()

    func testLibraryLoads() {
        XCTAssertGreaterThanOrEqual(library.workouts.count, 20)
        XCTAssertFalse(library.warmup.items.isEmpty)
        XCTAssertFalse(library.cooldown.items.isEmpty)
        XCTAssertEqual(library.workouts(in: .programme).map(\.id), ["session-a", "session-b", "session-c"])
    }

    func testEveryExerciseExists() {
        for workout in library.workouts {
            for item in workout.blocks.flatMap(\.items) {
                XCTAssertNotNil(library.exercise(item.exercise), "\(workout.id) uses unknown exercise \(item.exercise)")
            }
        }
    }

    func testWorkoutIDsAreUnique() {
        XCTAssertEqual(Set(library.workouts.map(\.id)).count, library.workouts.count)
    }

    func testWorkoutsAreAboutHalfAnHour() {
        for workout in library.workouts {
            let minutes = library.minutes(workout)
            XCTAssert((18...45).contains(minutes), "\(workout.title) is \(minutes) min")
        }
    }

    func testEveryWorkoutProducesSteps() {
        for workout in library.workouts {
            let steps = workout.steps(using: library)
            XCTAssertEqual(steps.first?.kind, .getReady, workout.id)
            XCTAssertNotEqual(steps.last?.kind, .rest, "\(workout.id) ends on rest")
            XCTAssertEqual(steps.map(\.id), Array(steps.indices), "\(workout.id) ids not sequential")
            XCTAssertTrue(steps.allSatisfy { $0.kind != .work || $0.exercise != nil }, workout.id)
        }
    }

    func testProgrammeRotation() {
        let history = [entry("session-a", daysAgo: 1), entry("swing-burn", daysAgo: 2)]
        XCTAssertEqual(library.nextProgrammeSession(history: history)?.id, "session-b")
        XCTAssertEqual(library.nextProgrammeSession(history: [entry("session-c", daysAgo: 1)])?.id, "session-a")
        XCTAssertEqual(library.nextProgrammeSession(history: [])?.id, "session-a")
    }

    func testFreshPicksAvoidRecentAndProgramme() {
        let history = [entry("swing-burn", daysAgo: 0), entry("emom-20", daysAgo: 1)]
        let picks = library.freshPicks(history: history)
        XCTAssertEqual(picks.count, 5)
        XCTAssertFalse(picks.contains { $0.category == .programme })
        XCTAssertFalse(picks.contains { $0.id == "swing-burn" || $0.id == "emom-20" })
    }

    private func entry(_ id: String, daysAgo: Int) -> CompletedWorkout {
        CompletedWorkout(workoutID: id, title: id, theme: "steel",
                         date: Calendar.current.date(byAdding: .day, value: -daysAgo, to: .now)!,
                         duration: 1800, completed: true, bellWeightKg: 16, effort: 3, notes: "",
                         setsDone: 0, setsTotal: 0)
    }
}
