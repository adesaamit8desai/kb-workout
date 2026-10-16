import XCTest
@testable import KBWorkout

@MainActor
final class SessionTests: XCTestCase {
    let library = WorkoutLibrary()

    private func makeSession(_ id: String = "session-a") -> WorkoutSession {
        let workout = library.workout(id: id)!
        let session = WorkoutSession(workout: workout,
                                     steps: workout.steps(using: library, options: StepOptions(includeWarmup: false)))
        session.voiceEnabled = false
        return session
    }

    func testDoneMovesToRestAndCountsTheSet() {
        let session = makeSession()
        session.start()
        session.skipForward()            // past "get ready"
        XCTAssertTrue(session.current.isRepSet)
        session.completeSet()
        XCTAssertEqual(session.current.kind, .rest)
        XCTAssertEqual(session.setsDone, 1)
        session.stop()
    }

    func testAddRest() {
        let session = makeSession()
        session.start()
        session.skipForward()
        session.completeSet()
        let before = session.stepRemaining
        session.addRest(15)
        XCTAssertEqual(session.stepRemaining, before + 15, accuracy: 0.5)
        session.stop()
    }

    func testSkipBackRestartsThenGoesBack() {
        let session = makeSession()
        session.start()
        session.skipForward()
        session.skipForward()
        XCTAssertEqual(session.index, 2)
        session.skipBack()
        XCTAssertEqual(session.index, 1)
        session.stop()
    }

    func testSkippingToTheEndFinishes() {
        let session = makeSession()
        session.start()
        for _ in session.steps { session.skipForward() }
        XCTAssertTrue(session.isFinished)
        XCTAssertFalse(session.endedEarly)
        XCTAssertEqual(session.setsDone, 0, "Skipped sets shouldn't count")
    }

    func testEndEarly() {
        let session = makeSession()
        session.start()
        session.end()
        XCTAssertTrue(session.isFinished)
        XCTAssertTrue(session.endedEarly)
    }

    func testPauseFreezesTheClock() async throws {
        let session = makeSession("emom-20")
        session.start()
        session.togglePause()
        let frozen = session.stepRemaining
        try await Task.sleep(for: .milliseconds(400))
        XCTAssertEqual(session.stepRemaining, frozen, accuracy: 0.01)
        session.togglePause()
        try await Task.sleep(for: .milliseconds(400))
        XCTAssertLessThan(session.stepRemaining, frozen)
        session.stop()
    }

    func testAmrapCounter() {
        let session = makeSession("amrap-20")
        session.start()
        session.skipForward()
        XCTAssertTrue(session.current.showsCounter)
        session.countRound()
        session.countRound()
        XCTAssertEqual(session.totalCount, 2)
        session.stop()
    }
}
