import StoreKit
import SwiftUI

struct PlusSubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.diaryPalette) private var palette
    @Environment(\.locale) private var locale
    @Environment(PurchaseStore.self) private var purchases
    @State private var loadRevision = 0
    @State private var didDismiss = false
    @State private var isShowingInformation = false

    var body: some View {
        @Bindable var purchases = purchases

        NavigationStack {
            Group {
                if purchases.subscriptions.isEmpty {
                    ScrollView {
                        marketingContent
                        if purchases.isLoading || !purchases.hasLoaded {
                            ProgressView("Loading purchases…")
                                .padding()
                        }
                    }
                    .background(palette.background)
                } else {
                    subscriptionContent
                }
            }
                .navigationTitle("MoodMargins Plus")
#if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
#endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close", systemImage: "xmark") { dismiss() }
                            .labelStyle(.iconOnly)
                            .accessibilityIdentifier("close-plus")
                    }
                }
        }
        .frame(idealHeight: 780)
        .presentationSizing(.form.fitted(horizontal: false, vertical: true))
        .sheet(isPresented: $isShowingInformation) {
            PlusInformationView()
                .environment(\.locale, locale)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .task(id: loadRevision) {
            if !purchases.hasLoaded || loadRevision > 0 { await purchases.loadProducts() }
        }
        .alert("Purchases", isPresented: $purchases.isShowingPurchaseMessage) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(purchases.purchaseMessage ?? "")
        }
    }

    private var subscriptionContent: some View {
        // Reuse products loaded by Customize instead of starting a second store request.
        SubscriptionStoreView(subscriptions: purchases.subscriptions) {
            marketingContent
#if os(iOS) || os(macOS)
            .containerBackground(for: .subscriptionStoreFullHeight) { palette.background }
#endif
        }
        .id(loadRevision)
        .tint(palette.action)
        .subscriptionStoreControlStyle(.compactPicker, placement: .scrollView)
        .subscriptionStorePickerItemBackground(palette.paper)
#if os(iOS) || os(macOS)
        .subscriptionStoreControlBackground(.clear)
#endif
        .subscriptionStoreButtonLabel(.action)
        .storeButton(.hidden, for: .cancellation)
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
    }

    private var marketingContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            PlusBenefitsView { isShowingInformation = true }
            // Unavailable individual themes don't prevent subscribing to Plus.
            if purchases.subscriptions.count < StoreProduct.subscriptions.count,
               purchases.loadingMessage != nil {
                Text("plusPlansUnavailable").font(.footnote).foregroundStyle(.secondary)
                Button("Try again", systemImage: "arrow.clockwise") { loadRevision += 1 }
                    .buttonStyle(.bordered)
            }
            if !AppStore.canMakePayments {
                Text("Purchases are restricted on this device.").foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: 680, alignment: .leading)
        .padding()
        // StoreKit supplies its commerce locale; keep our copy in the app's language.
        .environment(\.locale, locale)
    }

    private func dismissAfterUnlock() {
        guard !didDismiss else { return }
        didDismiss = true
        dismiss()
    }
}
