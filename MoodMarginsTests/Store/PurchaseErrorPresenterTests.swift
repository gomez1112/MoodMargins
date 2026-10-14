import Foundation
import StoreKit
import Testing
@testable import MoodMargins

@Suite("Purchase recovery")
@MainActor
struct PurchaseErrorPresenterTests {
    @Test("Cancellation, including nested store errors, remains silent")
    func cancellation() {
        #expect(PurchaseErrorPresenter.message(for: CancellationError()) == nil)
        #expect(PurchaseErrorPresenter.message(for: StoreKitError.userCancelled) == nil)
        #expect(PurchaseErrorPresenter.message(for: StoreKitError.networkError(URLError(.cancelled))) == nil)
        #expect(PurchaseErrorPresenter.message(for: StoreKitError.systemError(SKError(.paymentCancelled))) == nil)
    }

    @Test("Connection, account restrictions and storefront failures give distinct recovery instructions")
    func recovery() throws {
        let network = try #require(PurchaseErrorPresenter.message(for: StoreKitError.networkError(URLError(.notConnectedToInternet))))
        let restricted = try #require(PurchaseErrorPresenter.message(for: Product.PurchaseError.purchaseNotAllowed))
        let unavailable = try #require(PurchaseErrorPresenter.message(for: StoreKitError.notAvailableInStorefront))
        #expect(network != restricted)
        #expect(restricted != unavailable)
        #expect(network != unavailable)
        #expect(PurchaseErrorPresenter.message(for: StoreKitError.systemError(SKError(.paymentNotAllowed))) == restricted)
    }
}
