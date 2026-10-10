import StoreKitTest
import XCTest

/// Native StoreKit flows use a local test store and an isolated fictional journal.
final class PlusSubscriptionUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

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
            let close = app.buttons["xmark"].firstMatch
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
        app.buttons["Close"].tap()
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
