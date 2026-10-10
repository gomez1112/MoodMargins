/// Only verified, current StoreKit entitlements enter this value. StoreKit also includes
/// subscriptions in their billing grace period and excludes expired subscriptions.
struct PurchaseEntitlements: Equatable, Sendable {
    var products: Set<StoreProduct> = []

    var hasPlus: Bool { products.contains { $0.isSubscription } }

    func owns(_ theme: DiaryTheme) -> Bool {
        guard let product = theme.product else { return true }
        return products.contains(product)
    }

    func canUse(_ theme: DiaryTheme) -> Bool { hasPlus || owns(theme) }
}
