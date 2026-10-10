import Foundation
import StoreKit
import StoreKitTest
import Testing
@testable import MoodMargins

/// Uses Apple's local test store; no App Store account or real payment is involved.
@Suite("Purchase completion", .serialized)
@MainActor
struct PurchaseCompletionTests {
    @Test("Every verified subscription returns unlocked access for dismissal", arguments: StoreProduct.subscriptions)
    func verifiedSubscription(product: StoreProduct) async throws {
        let session = try testSession()
        defer { session.clearTransactions() }
        let verification = try await purchasedTransaction(product: product, session: session)
        let store = PurchaseStore()
        guard case .verified = verification else {
            Issue.record("The local StoreKit transaction was not verified")
            return
        }
        let unlocked = await store.handlePurchase(.success(.success(verification)))
        #expect(unlocked == product)
        #expect(store.entitlements.hasPlus)
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

    private func purchasedTransaction(product: StoreProduct, session: SKTestSession) async throws -> VerificationResult<Transaction> {
        let updates = Transaction.updates
        return try await withThrowingTaskGroup(of: VerificationResult<Transaction>.self) { group in
            group.addTask {
                for await verification in updates {
                    if verification.unsafePayloadValue.productID == product.rawValue { return verification }
                }
                throw CancellationError()
            }
            group.addTask {
                try await Task.sleep(for: .seconds(10))
                throw URLError(.timedOut)
            }
            defer { group.cancelAll() }
            try await session.buyProduct(identifier: product.rawValue)
            if let verification = await Transaction.latest(for: product.rawValue) { return verification }
            return try #require(await group.next())
        }
    }
}

private final class PurchaseTestBundle: NSObject {}
