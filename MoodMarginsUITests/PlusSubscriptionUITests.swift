import StoreKitTest
import XCTest

/// Native StoreKit flows use a local test store and an isolated fictional journal.
final class PlusSubscriptionUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    @MainActor
    func testPlusSheetPreservesThemePreviewAndToday() throws {
        let session = try testSession()
        defer { session.clearTransactions() }
        let app = launchPlus()
        defer { app.terminate() }
        app.buttons["close-plus"].tap()
        app.buttons["theme-botanical"].tap()
        let exploreTheme = app.buttons["Or explore MoodMargins Plus"]
        XCTAssertTrue(exploreTheme.waitForExistence(timeout: 10))
        if !exploreTheme.isHittable { app.scrollViews.firstMatch.swipeUp() }
        exploreTheme.tap()
        XCTAssertTrue(app.staticTexts["plusBenefitsTitle"].waitForExistence(timeout: 10))
        app.buttons["close-plus"].tap()
        XCTAssertTrue(app.navigationBars["Botanical"].exists)
        XCTAssertTrue(exploreTheme.isHittable)
        app.navigationBars["Botanical"].buttons.firstMatch.tap()
        let today = app.tabBars.buttons["Today"].firstMatch
        if today.exists { today.tap() } else { app.buttons["Today"].firstMatch.tap() }
        let exploreToday = app.buttons["Explore Plus"].firstMatch
        XCTAssertTrue(exploreToday.waitForExistence(timeout: 10))
        if !exploreToday.isHittable { app.scrollViews.firstMatch.swipeUp() }
        exploreToday.tap()
        XCTAssertTrue(app.staticTexts["plusBenefitsTitle"].waitForExistence(timeout: 10))
        app.buttons["close-plus"].tap()
        XCTAssertTrue(exploreToday.isHittable)
        XCTAssertTrue(app.staticTexts["Today's page"].exists)
    }

    @MainActor
    func testPlusSheetFitsOnIPadAndReturnsToCustomize() throws {
        let session = try testSession()
        defer { session.clearTransactions(); XCUIDevice.shared.orientation = .portrait }
        for landscape in [false, true] {
            XCUIDevice.shared.orientation = landscape ? .landscapeLeft : .portrait
            let app = launchPlus()
            defer { app.terminate() }
            try XCTSkipIf(app.frame.width < 900, "This workflow requires a full-width iPad.")
            let close = app.buttons["close-plus"]
            XCTAssertTrue(close.isHittable)
            XCTAssertLessThan(app.navigationBars["MoodMargins Plus"].frame.width, app.frame.width * 0.8)
            for name in ["Weekly", "Monthly", "Yearly"] {
                let plan = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", name)).firstMatch
                XCTAssertTrue(plan.waitForExistence(timeout: 15))
                XCTAssertTrue(plan.isHittable, "Every billing option should fit in the Plus sheet.")
                plan.tap()
                XCTAssertTrue(plan.isSelected)
            }
            XCTAssertTrue(app.buttons["Subscription Store View Button"].firstMatch.isHittable)
            XCTAssertTrue(app.buttons["Store View Restore Purchases"].firstMatch.isHittable)
            XCTAssertTrue(app.buttons["plusInformationButton"].isHittable)
            capture(app, name: "ipad-plus-\(landscape ? "landscape" : "portrait")")
            close.tap()
            XCTAssertTrue(app.staticTexts["plusBenefitsTitle"].waitForNonExistence(timeout: 10))
            XCTAssertTrue(app.navigationBars["Customize"].exists)
            app.terminate()
        }
    }

    @MainActor
    func testLocalizedPaywallsAllowEveryPlan() throws {
        let session = try testSession()
        defer { session.clearTransactions() }
        for language in ["es", "ar"] {
            let app = launchPlus(language: language)
            defer { app.terminate() }
            XCTAssertEqual(app.staticTexts["plusBenefitsTitle"].label, language == "ar" ? "مساحة لأسلوبك الخاص" : "Haz espacio para tu propio estilo")
            let weekly = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Weekly")).firstMatch
            let monthly = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Monthly")).firstMatch
            let yearly = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Yearly")).firstMatch
            XCTAssertTrue(weekly.waitForExistence(timeout: 15))
            XCTAssertTrue(monthly.waitForExistence(timeout: 15))
            XCTAssertTrue(yearly.waitForExistence(timeout: 15))
            for plan in [monthly, yearly, weekly] {
                plan.tap()
                XCTAssertTrue(plan.isSelected)
                XCTAssertTrue(app.staticTexts["plusBenefitsTitle"].exists)
            }
            let information = app.buttons["plusInformationButton"]
            XCTAssertTrue(information.isHittable)
            capture(app, name: "plus-paywall-\(language)")
            information.tap()
            let close = app.buttons["close-plus-information"]
            XCTAssertTrue(close.waitForExistence(timeout: 10))
            close.tap()
            XCTAssertTrue(app.staticTexts["plusBenefitsTitle"].exists)
            app.terminate()
        }
    }

    @MainActor
    func testAIInformationIsAvailableInASheet() throws {
        let session = try testSession()
        defer { session.clearTransactions() }
        let app = launchPlus()
        defer { app.terminate() }
        let information = app.buttons["plusInformationButton"]
        XCTAssertTrue(information.waitForExistence(timeout: 10))
        let details = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "AI tries Private Cloud Compute first")).firstMatch
        XCTAssertFalse(details.exists, "Detailed AI disclosures belong in the information sheet.")
        capture(app, name: "plus-paywall")
        information.tap()
        XCTAssertTrue(app.navigationBars["About Plus"].waitForExistence(timeout: 10))
        XCTAssertTrue(details.waitForExistence(timeout: 10))
        capture(app, name: "plus-information")
        app.buttons["close-plus-information"].tap()
        XCTAssertTrue(app.navigationBars["About Plus"].waitForNonExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Make room for your own style"].exists)
    }

    @MainActor
    func testSuccessfulSubscriptionDismissesPlus() throws {
        let session = try testSession()
        defer { session.clearTransactions() }
        let app = launchPlus()
        defer { app.terminate() }
        subscribe(in: app)
        XCTAssertTrue(app.staticTexts["Make room for your own style"].waitForNonExistence(timeout: 15))
        XCTAssertTrue(app.navigationBars["Customize"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Your subscription is active")).firstMatch.waitForExistence(timeout: 10))
    }

    @MainActor
    func testPendingSubscriptionStaysOpenUntilApproved() throws {
        let session = try testSession()
        defer { session.clearTransactions() }
        session.askToBuyEnabled = true
        let app = launchPlus()
        defer { app.terminate() }
        subscribe(in: app)
        let message = app.alerts.firstMatch
        XCTAssertTrue(message.waitForExistence(timeout: 10))
        XCTAssertTrue(message.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "waiting for approval")).firstMatch.exists)
        message.buttons["OK"].tap()
        XCTAssertTrue(app.staticTexts["Make room for your own style"].exists)
        let transaction = try XCTUnwrap(session.allTransactions().first { $0.productIdentifier == "com.transfinite.MoodMargins.plus.weekly" })
        try session.approveAskToBuyTransaction(identifier: transaction.identifier)
        XCTAssertTrue(app.staticTexts["Make room for your own style"].waitForNonExistence(timeout: 15))
        XCTAssertTrue(app.navigationBars["Customize"].waitForExistence(timeout: 10))
    }

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
    private func launchPlus(language: String = "en") -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--marketing-capture", "--marketing-tab", "customize", "-AppleLanguages", "(\(language))", "-AppleLocale", language == "ar" ? "ar_SA" : language == "es" ? "es_ES" : "en_US"]
        app.launch()
        let plus = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "MoodMargins Plus")).firstMatch
        XCTAssertTrue(plus.waitForExistence(timeout: 15), app.debugDescription)
        plus.tap()
        XCTAssertTrue(app.staticTexts["plusBenefitsTitle"].waitForExistence(timeout: 10), app.debugDescription)
        return app
    }

    @MainActor
    private func subscribe(in app: XCUIApplication) {
        let weekly = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Weekly")).firstMatch
        XCTAssertTrue(weekly.waitForExistence(timeout: 15), app.debugDescription)
        weekly.tap()
        // Picking a plan changes the selection; it must not dismiss before purchase.
        XCTAssertTrue(app.staticTexts["Make room for your own style"].exists)
        let subscribe = app.buttons["Subscription Store View Button"].firstMatch
        XCTAssertTrue(subscribe.waitForExistence(timeout: 10), app.debugDescription)
        subscribe.tap()
    }

    @MainActor
    private func capture(_ app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
