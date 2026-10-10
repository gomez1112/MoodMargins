import StoreKit
import SwiftUI

struct PlusSubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PurchaseStore.self) private var purchases
    @State private var loadRevision = 0
    @State private var didDismiss = false

    var body: some View {
        SubscriptionStoreView(productIDs: StoreProduct.subscriptions.map(\.rawValue)) {
            VStack(alignment: .leading, spacing: 20) {
                PlusBenefitsView()
                Text("AI requires Apple Intelligence readiness. Private Cloud Compute requires internet access and is subject to Apple's usage limits.")
                    .font(.footnote).foregroundStyle(.secondary)
                Text("A subscription unlocks premium themes while active. A theme purchased separately is yours to keep after a subscription ends.")
                    .font(.footnote).foregroundStyle(.secondary)
                if let message = purchases.loadingMessage {
                    Text(message).font(.footnote).foregroundStyle(.secondary)
                    Button("Try again", systemImage: "arrow.clockwise") { loadRevision += 1 }
                        .buttonStyle(.bordered)
                }
                if !AppStore.canMakePayments {
                    Text("Purchases are restricted on this device.").foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: 680, alignment: .leading)
            .padding()
        }
        .id(loadRevision)
        .storeButton(.visible, for: .restorePurchases)
        .subscriptionStorePolicyDestination(url: StoreLegal.termsURL, for: .termsOfService)
        .subscriptionStorePolicyDestination(url: StoreLegal.privacyURL, for: .privacyPolicy)
        .onInAppPurchaseCompletion { _, result in
            if let product = await purchases.handlePurchase(result), product.isSubscription {
                dismissAfterUnlock()
            }
        }
        .onChange(of: purchases.entitlements.hasPlus) { hadPlus, hasPlus in
            // Also handles Restore Purchases and approval of a previously pending purchase.
            if !hadPlus && hasPlus { dismissAfterUnlock() }
        }
        .navigationTitle("MoodMargins Plus")
        .task(id: loadRevision) { await purchases.loadProducts() }
    }

    private func dismissAfterUnlock() {
        guard !didDismiss else { return }
        didDismiss = true
        dismiss()
    }
}

private struct PlusBenefitsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Make room for your own style", systemImage: "sparkles")
                .font(.title2.bold())
            Label("Every premium theme, in light and dark", systemImage: "paintpalette")
            Label("AI tag suggestions from your notes", systemImage: "tag.fill")
            Label("Gentle recaps grounded in saved pages", systemImage: "text.book.closed")
            Text("AI tries Private Cloud Compute first, then the on-device model if needed. You can turn off cloud processing in Customize. Every billing plan includes the same features.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
