import XCTest
@testable import KBWorkout

final class StepTests: XCTestCase {
    let library = WorkoutLibrary()

    private func sessionA(_ options: StepOptions = StepOptions(includeWarmup: false)) -> [WorkoutStep] {
        library.workout(id: "session-a")!.steps(using: library, options: options)
    }

    func testSessionAStartsWithDeadliftSets() {
        let steps = sessionA()
        XCTAssertEqual(steps[0].kind, .getReady)
        let first = steps[1]
        XCTAssertEqual(first.kind, .work)
        XCTAssertFalse(first.isTimed)
        XCTAssertEqual(first.exercise?.id, "double_deadlift")
        XCTAssertEqual(first.reps, 6)
        XCTAssertEqual(first.progressLabel, "Set 1 of 4")
        XCTAssertEqual(steps[2].kind, .rest)
        XCTAssertEqual(steps[2].duration, 60)
    }

    func testPerSideSetsComeInPairs() {
        let press = sessionA().filter { $0.exercise?.id == "press" }
        XCTAssertEqual(press.count, 6)
        XCTAssertEqual(press.prefix(2).map(\.side), ["Left", "Right"])
    }

    func testRestBetweenSetsSetting() {
        let steps = sessionA(StepOptions(includeWarmup: false, restBetweenSets: 90))
        XCTAssertEqual(steps[2].duration, 90)
        // Timed conditioning rest is not affected.
        let conditioningRest = steps.last { $0.kind == .rest && $0.blockName.hasPrefix("Conditioning") }
        XCTAssertEqual(conditioningRest?.duration, 60)
    }

    func testWarmupAddsSections() {
        let steps = sessionA(StepOptions(includeWarmup: true))
        XCTAssertEqual(steps[1].section, .warmup)
        XCTAssertEqual(steps.last?.section, .cooldown)
        XCTAssertEqual(steps.first { $0.section == .main }?.mainBlockNumber, 1)
    }

    func testSetCountsMatchProgramme() {
        // 4 deadlift + 3 press + 3 row + 3 squat + 3 swing = 16 sets; 3 conditioning rounds.
        let steps = sessionA()
        XCTAssertEqual(steps.filter(\.countsAsSet).count, 16)
        XCTAssertEqual(steps.filter(\.countsAsInterval).count, 3)
    }
}
