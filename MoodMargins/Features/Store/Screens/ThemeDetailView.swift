import StoreKit
import SwiftUI

struct ThemeDetailView: View {
    @Environment(PurchaseStore.self) private var purchases
    @Environment(ThemePreferences.self) private var themes
    @Environment(NavigationContext.self) private var navigationContext
    @Environment(\.colorScheme) private var colorScheme
    @State private var previewScheme: ColorScheme?
    @State private var loadRevision = 0
    var theme: DiaryTheme

    var body: some View {
        ScrollView {
            AdaptiveContentWidth(maximumWidth: 680) {
                VStack(alignment: .leading, spacing: 24) {
                    Text(theme.description).font(.body).foregroundStyle(.secondary)
                    Picker("Preview appearance", selection: $previewScheme) {
                        Text("System").tag(ColorScheme?.none)
                        Text("Light").tag(ColorScheme?.some(.light))
                        Text("Dark").tag(ColorScheme?.some(.dark))
                    }
                    .pickerStyle(.segmented)
                    ThemePreviewView(theme: theme)
                        .accessibilityIdentifier("theme-preview")
                        .environment(\.colorScheme, previewScheme ?? colorScheme)
                    if purchases.entitlements.canUse(theme) {
                        Button(isSelected ? "Selected" : "Use this theme", systemImage: "checkmark") {
                            themes.select(theme, access: purchases.entitlements)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isSelected)
                        if theme != .pastel {
                            Text(purchases.entitlements.owns(theme) ? "You own this theme permanently." : "Included while your Plus subscription is active.")
                                .font(.footnote).foregroundStyle(.secondary)
                        }
                    } else {
                        if let identifier = theme.product {
                            ProductView(id: identifier.rawValue)
#if os(iOS) || os(macOS)
                                .productViewStyle(.compact)
#endif
                                .id(loadRevision)
                                .onInAppPurchaseCompletion { _, result in await purchases.handlePurchase(result) }
                        }
                        if let message = purchases.loadingMessage {
                            Text(message).font(.footnote).foregroundStyle(.secondary)
                            Button("Try again", systemImage: "arrow.clockwise") { loadRevision += 1 }
                                .buttonStyle(.bordered)
                        }
                        Text("One purchase keeps this theme permanently. No subscription is required.")
                            .font(.footnote).foregroundStyle(.secondary)
                        Button("Or explore MoodMargins Plus", systemImage: "sparkles") { navigationContext.presentSheet(.plus) }
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle(theme.title)
        .task(id: loadRevision) {
            if loadRevision > 0 || !purchases.hasLoaded { await purchases.loadProducts() }
        }
    }

    private var isSelected: Bool { themes.effectiveTheme(access: purchases.entitlements) == theme }
}
