import FoundationModels
import StoreKit
import SwiftUI

struct StoreView: View {
    @Environment(PurchaseStore.self) private var purchases
    @Environment(ThemePreferences.self) private var themes
    @Environment(FoundationModelPreferences.self) private var modelPreferences
#if DEBUG
    @Environment(MarketingCaptureState.self) private var marketingCapture
#endif
    @State private var isManagingSubscriptions = false
    @State private var restoreRevision = 0
    @State private var loadRevision = 0

    var body: some View {
        @Bindable var modelPreferences = modelPreferences
        Form {
            Section {
                NavigationLink {
                    PlusSubscriptionView()
                } label: {
                    Label {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("MoodMargins Plus").font(.headline)
                            Text(purchases.entitlements.hasPlus ? "Your subscription is active" : "Premium themes, AI tags, and gentle recaps")
                                .font(.subheadline).foregroundStyle(.secondary)
                        }
                    } icon: { Image(systemName: "sparkles") }
                }
            } footer: {
                Text("Your journal and standard Insights stay free. Plus has the same features with weekly, monthly, or yearly billing.")
            }
            Section {
                ForEach(DiaryTheme.allCases) { theme in
                    NavigationLink(value: theme) {
                        ThemeStoreRow(theme: theme, status: status(for: theme))
                    }
                    .accessibilityIdentifier("theme-\(theme.rawValue)")
                }
            } header: {
                Text("Themes")
            } footer: {
                Text("Buy a theme once to keep it, or use every premium theme while Plus is active. All themes include light and dark appearances.")
            }
            Section {
                Toggle("Use Private Cloud Compute", systemImage: "cloud", isOn: $modelPreferences.usesPrivateCloudCompute)
                if purchases.entitlements.hasPlus, modelPreferences.usesPrivateCloudCompute {
                    if let status = FoundationModelService.status(for: .privateCloudCompute) {
                        Text(status).font(.subheadline).foregroundStyle(.secondary)
                    }
                    if FoundationModelService.canAttemptCloud, let suggestion = FoundationModelService.cloudModel.quotaUsage.limitIncreaseSuggestion {
                        Button("Manage cloud limit", systemImage: "cloud") { suggestion.show() }
                    }
                }
            } header: {
                Text("Apple Intelligence")
            } footer: {
                Text("Plus suggests tags and creates recaps automatically. When enabled, journal text needed for AI is sent to Apple's Private Cloud Compute. If a cloud request fails, the on-device model is used. Turn this off to keep AI requests on your device.")
            }
            Section("Purchases") {
                Button("Restore purchases", systemImage: "arrow.clockwise") { restoreRevision += 1 }
                    .disabled(purchases.isRestoring)
                if purchases.isRestoring { ProgressView("Restoring purchases…") }
#if os(macOS)
                Link("Manage subscription", destination: StoreLegal.subscriptionsURL)
#else
                Button("Manage subscription", systemImage: "creditcard") { isManagingSubscriptions = true }
#endif
                if purchases.isLoading {
                    ProgressView("Loading purchases…")
                } else if let message = purchases.loadingMessage {
                    Text(message).foregroundStyle(.secondary)
                    Button("Try again", systemImage: "arrow.clockwise") { loadRevision += 1 }
                }
                if !AppStore.canMakePayments {
                    Text("Purchases are restricted on this device. You can still use your journal and preview themes.")
                        .foregroundStyle(.secondary)
                }
            }
            Section("About") {
                NavigationLink("Privacy policy") { PrivacyPolicyView() }
                Link("Privacy policy on the web", destination: StoreLegal.privacyURL)
                Link("Terms of use", destination: StoreLegal.termsURL)
            }
#if DEBUG
            Section {
                Toggle("Screenshot preview", isOn: Binding(get: { marketingCapture.isEnabled }, set: marketingCapture.setEnabled))
                if let message = marketingCapture.errorMessage { Text(message).foregroundStyle(.secondary) }
            } header: { Text("Development") } footer: {
                Text("Uses fictional entries in a separate preview store. Your journal stays in its own store. This option is excluded from App Store builds.")
            }
#endif
        }
        .formStyle(.grouped)
        .navigationTitle("Customize")
        .navigationDestination(for: DiaryTheme.self) { theme in ThemeDetailView(theme: theme) }
#if !os(macOS)
        .manageSubscriptionsSheet(isPresented: $isManagingSubscriptions)
#endif
        .task(id: loadRevision) { await purchases.loadProducts() }
        .task(id: restoreRevision) {
            if restoreRevision > 0 { await purchases.restorePurchases() }
        }
    }

    private func status(for theme: DiaryTheme) -> String {
        if themes.effectiveTheme(access: purchases.entitlements) == theme { return String(localized: "Selected") }
        if theme == .pastel { return String(localized: "Free") }
        if purchases.entitlements.owns(theme) { return String(localized: "Purchased") }
        if purchases.entitlements.hasPlus { return String(localized: "Included with Plus") }
        return theme.product.flatMap(purchases.product)?.displayPrice ?? String(localized: "Preview")
    }
}

private struct ThemeStoreRow: View {
    var theme: DiaryTheme
    var status: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: theme.symbol)
                .font(.title2)
                .foregroundStyle(theme.palette.ink)
                .frame(width: 48, height: 48)
                .background(theme.palette.background, in: .rect(cornerRadius: 12))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(theme.title).font(.headline)
                Text(theme.description).font(.subheadline).foregroundStyle(.secondary)
                Text(status).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
