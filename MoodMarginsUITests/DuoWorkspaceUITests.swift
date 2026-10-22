import XCTest

#if os(iOS)
/// Exercises the native compact browser/detail flow with an isolated journal.
final class DuoWorkspaceUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    @MainActor
    func testSelectedPageKeepsItsDraftAcrossBrowserNavigation() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--marketing-capture", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        defer { app.terminate() }

        let note = app.textFields["journal-note"].firstMatch
        XCTAssertTrue(note.waitForExistence(timeout: 15))
        note.tap()
        note.typeText(" A quiet moment to remember.")
        app.buttons["dismiss-journal-keyboard"].firstMatch.tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForNonExistence(timeout: 10))
        selectTab("Page", in: app)
        XCTAssertTrue(note.waitForExistence(timeout: 10))
        XCTAssertTrue((note.value as? String)?.contains("A quiet moment to remember.") == true)

        let back = app.buttons["BackButton"].firstMatch
        if back.exists { back.tap() }
        let browser = app.descendants(matching: .any)["page-browser"].firstMatch
        XCTAssertTrue(browser.waitForExistence(timeout: 10))
        let selected = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "past-page-")).firstMatch
        XCTAssertTrue(selected.waitForExistence(timeout: 10))
        if !selected.isHittable { browser.swipeUp() }
        selected.tap()
        XCTAssertTrue(note.waitForExistence(timeout: 10))
        XCTAssertTrue((note.value as? String)?.contains("A quiet moment to remember.") == true)
        selectTab("Today", in: app)
        XCTAssertTrue((note.value as? String)?.contains("A quiet moment to remember.") == true)
    }

    @MainActor
    private func selectTab(_ title: String, in app: XCUIApplication) {
        let tab = app.tabBars.buttons[title].firstMatch
        if tab.exists { tab.tap() } else { app.buttons[title].firstMatch.tap() }
    }
}
#endif
