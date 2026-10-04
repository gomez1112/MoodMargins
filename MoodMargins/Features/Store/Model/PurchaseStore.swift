import Foundation
import Observation
import StoreKit

@MainActor
@Observable
final class PurchaseStore {
    private(set) var products: [Product] = []
    private(set) var entitlements = PurchaseEntitlements()
    private(set) var isLoading = false
    private(set) var isRestoring = false
    private(set) var hasLoaded = false
    var loadingMessage: String?
    var purchaseMessage: String?
    private var refreshID: UUID?

    var isShowingPurchaseMessage: Bool {
        get { purchaseMessage != nil }
        set { if !newValue { purchaseMessage = nil } }
    }

    var subscriptions: [Product] {
        StoreProduct.subscriptions.compactMap { product($0) }
    }

    func product(_ identifier: StoreProduct) -> Product? {
        products.first { $0.id == identifier.rawValue }
    }

    func loadProducts() async {
        guard !isLoading else { return }
        isLoading = true
        loadingMessage = nil
        defer { isLoading = false }
        do {
            let loaded = try await Product.products(for: StoreProduct.allCases.map(\.rawValue))
            try Task.checkCancellation()
            products = loaded
            hasLoaded = true
            if loaded.count != StoreProduct.allCases.count {
                loadingMessage = String(localized: "Some purchases are unavailable right now. You can still preview every theme.")
            }
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else { return }
            hasLoaded = true
            loadingMessage = String(localized: "Purchases couldn't be loaded. Check your connection and try again.")
        }
    }

    func refreshEntitlements() async {
        let requestID = UUID()
        refreshID = requestID
        var verifiedProducts: Set<StoreProduct> = []
        for await result in Transaction.currentEntitlements {
            guard !Task.isCancelled else { return }
            guard case .verified(let transaction) = result,
                  transaction.revocationDate == nil, !transaction.isUpgraded,
                  let product = StoreProduct(rawValue: transaction.productID) else { continue }
            verifiedProducts.insert(product)
        }
        guard !Task.isCancelled, refreshID == requestID else { return }
        entitlements = PurchaseEntitlements(products: verifiedProducts)
    }

    /// Each window owns a cancellable observer; finishing a verified transaction is idempotent.
    func observeTransactions() async {
        for await result in Transaction.updates {
            guard !Task.isCancelled else { return }
            guard case .verified(let transaction) = result,
                  StoreProduct(rawValue: transaction.productID) != nil else { continue }
            await refreshEntitlements()
            await transaction.finish()
        }
    }

    func observeSubscriptionStatus() async {
        for await status in Product.SubscriptionInfo.Status.updates {
            guard !Task.isCancelled else { return }
            guard case .verified(let transaction) = status.transaction,
                  case .verified = status.renewalInfo,
                  StoreProduct(rawValue: transaction.productID)?.isSubscription == true else { continue }
            await refreshEntitlements()
        }
    }

    func restorePurchases() async {
        guard !isRestoring else { return }
        isRestoring = true
        defer { isRestoring = false }
        do {
            try await AppStore.sync()
            try Task.checkCancellation()
            await refreshEntitlements()
            purchaseMessage = entitlements.products.isEmpty
                ? String(localized: "No current purchases were found for this Apple Account.")
                : String(localized: "Your purchases are restored.")
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else { return }
            if let storeError = error as? StoreKitError, case .userCancelled = storeError { return }
            purchaseMessage = String(localized: "Your purchases couldn't be restored. Please try again.")
        }
    }

    func handlePurchase(_ result: Result<Product.PurchaseResult, Error>) async {
        switch result {
        case .success(.success(let verification)):
            guard case .verified(let transaction) = verification else {
                purchaseMessage = String(localized: "This purchase couldn't be verified. Restore purchases or try again.")
                return
            }
            await refreshEntitlements()
            await transaction.finish()
        case .success(.pending):
            purchaseMessage = String(localized: "Your purchase is waiting for approval. Access will unlock when Apple confirms it.")
        case .success(.userCancelled): break
        case .failure(let error):
            guard !(error is CancellationError), !Task.isCancelled else { return }
            if let storeError = error as? StoreKitError, case .userCancelled = storeError { return }
            purchaseMessage = String(localized: "Your purchase couldn't be completed. Please try again.")
        @unknown default: break
        }
    }
}
