import XCTest

/// Real app captures use a DEBUG-only in-memory journal and never grant purchase access.
final class JournalCaptureUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    @MainActor
    func testJournalAutosave() throws {
        let app = launch(language: "en")
        defer { app.terminate() }
        let note = app.textFields["journal-note"].firstMatch
        XCTAssertTrue(note.waitForExistence(timeout: 15))
        note.tap()
        note.typeText(" Small things made today feel lighter.")
        let done = app.buttons["dismiss-journal-keyboard"].firstMatch
        XCTAssertTrue(done.waitForExistence(timeout: 10))
        done.tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForNonExistence(timeout: 10))
        selectTab("Page", in: app)
        XCTAssertTrue(app.staticTexts["Calendar stickers"].waitForExistence(timeout: 10))
        XCTAssertTrue((note.value as? String)?.contains("Small things made today feel lighter.") == true)
        selectTab("Today", in: app)
        XCTAssertTrue((note.value as? String)?.contains("Small things made today feel lighter.") == true)
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Saved automatically")).firstMatch.waitForExistence(timeout: 10))
    }

    @MainActor func testCaptureEnglish() throws { try captureLanguage("en") }
    @MainActor func testCaptureSpanish() throws { try captureLanguage("es") }
    @MainActor func testCaptureArabic() throws { try captureLanguage("ar") }

    @MainActor
    private func launch(language: String, dark: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--marketing-capture", "-AppleLanguages", "(\(language))", "-AppleLocale", language == "ar" ? "ar_SA" : language == "es" ? "es_ES" : "en_US"]
        if dark { app.launchArguments.append("--marketing-dark") }
        app.launch()
        return app
    }

    @MainActor
    private func captureLanguage(_ language: String) throws {
        let titles = language == "ar" ? ["اليوم", "الصفحة", "الرؤى", "تخصيص"] : language == "es" ? ["Hoy", "Página", "Perspectivas", "Personalizar"] : ["Today", "Page", "Insights", "Customize"]
        let app = launch(language: language)
        defer { app.terminate() }
        XCTAssertTrue(app.textFields["journal-note"].firstMatch.waitForExistence(timeout: 15))
        capture(app, name: "today", language: language)
        selectTab(titles[1], in: app)
        XCTAssertTrue(app.textFields["journal-note"].firstMatch.waitForExistence(timeout: 10))
        capture(app, name: "pages", language: language)
        selectTab(titles[2], in: app)
        let fortnight = app.buttons.matching(identifier: "insight-range-14").firstMatch
        XCTAssertTrue(fortnight.waitForExistence(timeout: 10), app.debugDescription)
        fortnight.tap()
        capture(app, name: "insights", language: language)
        app.scrollViews.firstMatch.swipeUp()
        capture(app, name: "stickers", language: language)
        selectTab(titles[3], in: app)
        capture(app, name: "customize", language: language)
        for theme in ["botanical", "coastal", "sunset"] {
            let link = app.buttons["theme-\(theme)"].firstMatch
            if !link.isHittable { app.scrollViews.firstMatch.swipeUp() }
            XCTAssertTrue(link.waitForExistence(timeout: 10), app.debugDescription)
            link.tap()
            XCTAssertTrue(app.descendants(matching: .any)["theme-preview"].firstMatch.waitForExistence(timeout: 10))
            capture(app, name: theme, language: language)
            app.navigationBars.buttons.firstMatch.tap()
        }
        app.terminate()
        let night = launch(language: language, dark: true)
        defer { night.terminate() }
        selectTab(titles[2], in: night)
        XCTAssertTrue(night.buttons["insight-range-14"].firstMatch.waitForExistence(timeout: 10))
        capture(night, name: "dark", language: language)
    }

    @MainActor
    private func selectTab(_ title: String, in app: XCUIApplication) {
        let tab = app.tabBars.buttons[title].firstMatch
        if tab.exists { tab.tap(); return }
        let button = app.buttons[title].firstMatch
        XCTAssertTrue(button.waitForExistence(timeout: 10), app.debugDescription)
        button.tap()
    }

    @MainActor
    private func capture(_ app: XCUIApplication, name: String, language: String) {
        // Product loading can provoke a system Apple Account verification sheet.
        // Decline it before recording; marketing never includes account information.
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let alert = springboard.alerts.firstMatch
        if alert.exists {
            let dismiss = alert.buttons.matching(NSPredicate(format: "label == 'Not Now' OR label == 'Cancel'")).firstMatch
            XCTAssertTrue(dismiss.exists, "Unexpected system alert: \(alert.label)")
            dismiss.tap()
            XCTAssertTrue(alert.waitForNonExistence(timeout: 10))
        }
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "marketing-\(language)-\(name)"
        attachment.lifetime = .keepAlways
        add(attachment)
        do {
            let directory = URL.documentsDirectory.appending(path: "MoodMargins-Captures/\(language)", directoryHint: .isDirectory)
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let device = app.frame.width > 700 ? "ipad" : "iphone"
            try screenshot.pngRepresentation.write(to: directory.appending(path: "\(device)-\(name).png"))
        } catch { XCTFail("Could not export the app screenshot: \(error)") }
    }
}
