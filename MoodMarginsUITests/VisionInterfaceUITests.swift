#if os(visionOS)
import StoreKitTest
import XCTest

/// Local StoreKit testing checks the native views; it doesn't prove Apple's device sandbox works.
final class VisionInterfaceUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    @MainActor
    func testWelcomeUsesTheSameThreePagesAsPhoneAndMac() throws {
        // An earlier commerce test must not enable live AI work in this UI fixture.
        let session = try testSession()
        defer { session.clearTransactions() }
        let app = XCUIApplication()
        app.launchArguments = ["--marketing-capture", "--show-onboarding", "-com.onboardingkit.lastSeenVersion", "", "-AppleLanguages", "(en)"]
        app.launch()
        defer { app.terminate() }
        let next = app.buttons["onboarding-next"]
        XCTAssertTrue(next.waitForExistence(timeout: 15))
        XCTAssertTrue(next.isHittable)
        assertPage(app, contains: "A softer place to check in")
        capture(app, name: "vision-welcome")
        next.tap()
        assertPage(app, contains: "Build today with gentle tags")
        XCTAssertTrue(next.isHittable)
        next.tap()
        assertPage(app, contains: "See patterns without pressure")
        let start = app.buttons["start-journaling"]
        XCTAssertTrue(start.isHittable)
        start.tap()
        XCTAssertTrue(app.staticTexts["Today's page"].waitForExistence(timeout: 10))
        capture(app, name: "vision-today")
    }

    @MainActor
    func testNativeThemePurchaseUnlocksPermanentTheme() throws {
        let session = try testSession()
        defer { session.clearTransactions() }
        let app = launchCustomize()
        defer { app.terminate() }
        app.buttons["theme-botanical"].tap()
        let buy = app.buttons.matching(NSPredicate(format: "label CONTAINS %@ OR label == %@", "1.99", "Buy")).firstMatch
        XCTAssertTrue(buy.waitForExistence(timeout: 15), app.debugDescription)
        if !buy.isHittable { app.scrollViews.firstMatch.swipeUp() }
        capture(app, name: "vision-theme-store")
        buy.tap()
        let useTheme = app.buttons["Use this theme"]
        XCTAssertTrue(useTheme.waitForExistence(timeout: 15), app.debugDescription)
        XCTAssertTrue(app.staticTexts["You own this theme permanently."].exists)
        useTheme.tap()
        XCTAssertTrue(app.buttons["Selected"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testWelcomeSupportsLargeTextAndArabic() throws {
        let session = try testSession()
        defer { session.clearTransactions() }
        let app = XCUIApplication()
        app.launchArguments = ["--marketing-capture", "--show-onboarding", "-com.onboardingkit.lastSeenVersion", "", "-AppleLanguages", "(ar)", "-AppleLocale", "ar_SA", "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        defer { app.terminate() }
        let next = app.buttons["onboarding-next"]
        XCTAssertTrue(next.waitForExistence(timeout: 15))
        XCTAssertTrue(next.isHittable)
        XCTAssertEqual(next.label, "التالي")
        capture(app, name: "vision-welcome-arabic-large-text")
        next.tap()
        XCTAssertTrue(next.isHittable)
        next.tap()
        let start = app.buttons["start-journaling"]
        XCTAssertTrue(start.waitForExistence(timeout: 5))
        XCTAssertTrue(start.isHittable)
        XCTAssertEqual(start.label, "ابدأ التدوين")
        start.tap()
        XCTAssertTrue(start.waitForNonExistence(timeout: 5))
    }

    @MainActor
    func testNativeSubscriptionUnlocksAndDismissesSheet() throws {
        let session = try testSession()
        defer { session.clearTransactions() }
        let app = launchCustomize()
        defer { app.terminate() }
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "MoodMargins Plus")).firstMatch.tap()
        let yearly = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Yearly")).firstMatch
        XCTAssertTrue(yearly.waitForExistence(timeout: 15), app.debugDescription)
        capture(app, name: "vision-subscriptions")
        yearly.tap()
        let purchase = app.buttons["Subscription Store View Button"].firstMatch
        if purchase.waitForExistence(timeout: 2) { purchase.tap() }
        XCTAssertTrue(app.staticTexts["Your subscription is active"].waitForExistence(timeout: 15), app.debugDescription)
        XCTAssertFalse(app.buttons["close-plus"].exists)
    }

    @MainActor
    private func testSession() throws -> SKTestSession {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "PurchaseCompletion", withExtension: "storekit"))
        let session = try SKTestSession(contentsOf: url)
        session.resetToDefaultState()
        session.clearTransactions()
        session.disableDialogs = true
        session.timeRate = .realTime
        return session
    }

    @MainActor
    private func launchCustomize() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--marketing-capture", "--marketing-tab", "customize", "-selectedDiaryTheme", "pastel", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        XCTAssertTrue(app.buttons["theme-botanical"].waitForExistence(timeout: 15))
        return app
    }

    @MainActor
    private func capture(_ app: XCUIApplication, name: String) {
        // visionOS has spatial windows; XCUIScreen returns an empty 1×1 image here.
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    private func assertPage(_ app: XCUIApplication, contains title: String) {
        let page = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", title)).firstMatch
        XCTAssertTrue(page.waitForExistence(timeout: 5), app.debugDescription)
    }
}
#endif
