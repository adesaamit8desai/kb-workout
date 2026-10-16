import XCTest

/// Walks through the main flows and saves a screenshot of every screen.
/// Screenshots go to $SCREENSHOT_DIR (set by CI via TEST_RUNNER_SCREENSHOT_DIR).
final class FlowTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    private func launch(_ extra: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-voiceEnabled", "NO", "-timeScale", "20",
                               "-includeWarmup", "NO"] + extra
        app.launch()
        return app
    }

    private func snap(_ name: String) {
        let shot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        if let dir = ProcessInfo.processInfo.environment["SCREENSHOT_DIR"], !dir.isEmpty {
            try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
            try? shot.pngRepresentation.write(to: URL(fileURLWithPath: dir).appendingPathComponent("\(name).png"))
        }
    }

    private func waitFor(_ element: XCUIElement, _ what: String, timeout: TimeInterval = 10) {
        XCTAssertTrue(element.waitForExistence(timeout: timeout), "Couldn't find \(what)")
    }

    func testFullSessionA() {
        let app = launch()
        waitFor(app.staticTexts["Workouts"], "home title")
        snap("01-home")

        app.buttons["upNext"].tap()
        waitFor(app.buttons["startWorkout"], "Start button")
        snap("02-detail")
        app.swipeUp()
        snap("03-detail-exercises")
        app.swipeDown()

        app.buttons["startWorkout"].tap()
        // Get ready lasts 10 s, shortened by -timeScale.
        waitFor(app.buttons["doneSet"], "Done button")
        snap("04-rep-set")

        app.buttons["doneSet"].tap()
        waitFor(app.buttons["skipRest"], "Skip rest")
        snap("05-rest")
        app.buttons["skipRest"].tap()
        waitFor(app.buttons["doneSet"], "second set")
        snap("06-second-set")

        // Skip forward to the timed conditioning finisher.
        var reachedInterval = false
        for _ in 0..<60 {
            if app.staticTexts["WORK"].exists { reachedInterval = true; break }
            let skip = app.buttons["skipStep"].firstMatch
            guard skip.waitForExistence(timeout: 3) else { break }
            skip.tap()
        }
        XCTAssertTrue(reachedInterval, "Never reached a timed interval")
        snap("07-interval")

        app.buttons["endWorkout"].tap()
        app.buttons["Finish and Save"].tap()
        waitFor(app.buttons["saveWorkout"], "Save button")
        snap("08-summary")
        app.buttons["saveWorkout"].tap()

        app.tabBars.buttons["History"].tap()
        waitFor(app.staticTexts["Session A"], "saved workout in history")
        snap("09-history-after-save")
    }

    /// Scrolls the page and horizontal shelves until the element can be tapped.
    private func reveal(_ element: XCUIElement, in app: XCUIApplication) {
        let screen = app.windows.firstMatch.frame
        let visibleArea = screen.insetBy(dx: 0, dy: 100)
        for _ in 0..<15 {
            if element.exists && visibleArea.contains(element.frame) { return }
            let frame = element.frame
            if !element.exists || frame.maxY > visibleArea.maxY {
                drag(app, from: 0.7, to: 0.45)        // small scroll up
            } else if frame.minY < visibleArea.minY {
                drag(app, from: 0.4, to: 0.65)        // small scroll down
            } else {
                let y = frame.midY / screen.height
                app.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: y))
                    .press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.15, dy: y)))
            }
        }
    }

    private func drag(_ app: XCUIApplication, from: CGFloat, to: CGFloat) {
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.05, dy: from))
            .press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.05, dy: to)))
    }

    func testAmrapCounter() {
        let app = launch()
        waitFor(app.staticTexts["Workouts"], "home title")
        let card = app.buttons["workout-amrap-20"].firstMatch
        reveal(card, in: app)
        guard app.windows.firstMatch.frame.contains(card.frame) else {
            snap("10-amrap-not-found")
            return XCTFail("Couldn't reach the AMRAP 20 card")
        }
        card.tap()
        app.buttons["startWorkout"].tap()
        waitFor(app.buttons["countRound"], "round counter", timeout: 15)
        app.buttons["countRound"].tap()
        app.buttons["countRound"].tap()
        snap("10-amrap")
    }

    func testScreensWithHistory() {
        let app = launch(["-seedHistory"])
        waitFor(app.staticTexts["Workouts"], "home title")
        snap("11-home-with-history")
        app.swipeUp()
        snap("12-home-shelves")
        app.tabBars.buttons["History"].tap()
        waitFor(app.staticTexts["History"], "history title")
        snap("13-history")
    }
}
