import Foundation
import StoreKit
import StoreKitTest
import Testing
#if os(visionOS)
import UIKit
#endif
@testable import MoodMargins

/// Uses Apple's local test store; no App Store account or real payment is involved.
@Suite("Purchase completion", .serialized)
@MainActor
struct PurchaseCompletionTests {
    @Test("Verified subscriptions and permanent themes unlock access", arguments: StoreProduct.allCases)
    func verifiedProduct(product: StoreProduct) async throws {
        let session = try testSession()
        defer { session.clearTransactions() }
        let result = try await purchase(product: product)
        guard case .success(let verification) = result else {
            Issue.record("The local purchase didn't return a transaction")
            return
        }
        let store = PurchaseStore()
        guard case .verified = verification else {
            Issue.record("The local StoreKit transaction was not verified")
            return
        }
        let unlocked = await store.handlePurchase(.success(.success(verification)))
        #expect(unlocked == product)
        #expect(store.entitlements.products.contains(product))
        #expect(store.entitlements.hasPlus == product.isSubscription)
        #expect(store.purchaseMessage == nil)
    }

    @Test("Pending, cancelled, and failed purchases never signal dismissal")
    func incompletePurchases() async {
        let store = PurchaseStore()
        #expect(await store.handlePurchase(.success(.pending)) == nil)
        #expect(store.purchaseMessage != nil)
        #expect(!store.entitlements.hasPlus)
        store.purchaseMessage = nil
        #expect(await store.handlePurchase(.success(.userCancelled)) == nil)
        #expect(store.purchaseMessage == nil)
        #expect(await store.handlePurchase(.failure(CancellationError())) == nil)
        #expect(store.purchaseMessage == nil)
        #expect(await store.handlePurchase(.failure(URLError(.notConnectedToInternet))) == nil)
        #expect(store.purchaseMessage != nil)
        #expect(!store.entitlements.hasPlus)
    }

    private func testSession() throws -> SKTestSession {
        let url = try #require(Bundle(for: PurchaseTestBundle.self).url(forResource: "PurchaseCompletion", withExtension: "storekit"))
        let session = try SKTestSession(contentsOf: url)
        session.resetToDefaultState()
        session.clearTransactions()
        session.disableDialogs = true
        session.timeRate = .realTime
        return session
    }

    private func purchase(product: StoreProduct) async throws -> Product.PurchaseResult {
        let loaded = try await Product.products(for: [product.rawValue])
        let product = try #require(loaded.first)
#if os(visionOS)
        // Test-only UIKit access: StoreKit's programmatic visionOS API requires a scene.
        // Shipping purchase controls use native StoreKit views and don't use this bridge.
        let scene = try #require(UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive })
        return try await product.purchase(confirmIn: scene)
#else
        return try await product.purchase()
#endif
    }
}

private final class PurchaseTestBundle: NSObject {}
