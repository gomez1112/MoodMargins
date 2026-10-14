import Foundation
import Observation
import StoreKit
import OSLog

@MainActor
@Observable
final class PurchaseStore {
    private static let logger = Logger(subsystem: "com.transfinite.MoodMargins", category: "Purchases")
    private(set) var products: [Product] = []
    private(set) var entitlements = PurchaseEntitlements()
    private(set) var isLoading = false
    private(set) var isRestoring = false
    private(set) var hasLoaded = false
    private(set) var hasResolvedEntitlements = false
    var loadingMessage: String?
    var purchaseMessage: String?
    private var refreshID: UUID?

    /// Do not instantiate the ad SDK while a returning subscriber's access is unknown.
    var canShowExchangeBanner: Bool {
        hasResolvedEntitlements && !entitlements.hasPlus
    }

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
                let missing = StoreProduct.allCases.filter { identifier in !loaded.contains { $0.id == identifier.rawValue } }
                Self.logger.error("StoreKit did not return products: \(missing.map(\.rawValue).joined(separator: ","), privacy: .public)")
            }
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else { return }
            hasLoaded = true
            Self.log(error, operation: "load products")
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
        hasResolvedEntitlements = true
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

    /// Returns the verified product only after its current access has been refreshed.
    @discardableResult
    func handlePurchase(_ result: Result<Product.PurchaseResult, Error>, product: StoreProduct? = nil) async -> StoreProduct? {
        switch result {
        case .success(.success(let verification)):
            guard case .verified(let transaction) = verification else {
                if case .unverified(_, let error) = verification {
                    Self.log(error, operation: "verify transaction")
                }
                purchaseMessage = String(localized: "This purchase couldn't be verified. Restore purchases or try again.")
                return nil
            }
            await refreshEntitlements()
            await transaction.finish()
            guard !Task.isCancelled, transaction.revocationDate == nil, !transaction.isUpgraded,
                  let product = StoreProduct(rawValue: transaction.productID),
                  entitlements.products.contains(product) else { return nil }
            return product
        case .success(.pending):
            purchaseMessage = String(localized: "Your purchase is waiting for approval. Access will unlock when Apple confirms it.")
        case .success(.userCancelled): break
        case .failure(let error):
            guard !Task.isCancelled, let message = PurchaseErrorPresenter.message(for: error) else { return nil }
            Self.log(error, operation: "purchase \(product?.rawValue ?? "unknown product")")
            purchaseMessage = message
        @unknown default: break
        }
        return nil
    }

    private static func log(_ error: Error, operation: String) {
        let diagnostic = error as NSError
        logger.error("StoreKit \(operation, privacy: .public) failed: \(diagnostic.domain, privacy: .public) / \(diagnostic.code, privacy: .public). \(diagnostic.localizedDescription, privacy: .private)")
    }
}
