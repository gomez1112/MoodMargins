import SwiftUI

/// Each window owns its routes and presentations; journal data and purchases remain shared.
struct JournalSceneRoot: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(PurchaseStore.self) private var purchases
    @State private var navigationContext: NavigationContext
#if DEBUG
    @Environment(MarketingCaptureState.self) private var marketingCapture
#endif

    init() {
        let navigation = NavigationContext()
#if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--marketing-capture"),
           let index = arguments.firstIndex(of: "--marketing-tab"),
           arguments.indices.contains(index + 1),
           let tab = AppTab(rawValue: arguments[index + 1]) {
            navigation.selectedTab = tab
        }
#endif
        _navigationContext = State(initialValue: navigation)
    }

    var body: some View {
        rootContent
            .environment(navigationContext)
            .task { await purchases.observeTransactions() }
            .task { await purchases.observeSubscriptionStatus() }
            .task(id: scenePhase) {
                if scenePhase == .active { await purchases.refreshEntitlements() }
            }
#if DEBUG
            .task { await runMarketingCaptureIfRequested() }
#endif
    }

    @ViewBuilder
    private var rootContent: some View {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--marketing-capture"),
           !ProcessInfo.processInfo.arguments.contains("--show-onboarding") {
            ContentView()
        } else {
            MoodMarginsOnboarding { ContentView() }
        }
#else
        MoodMarginsOnboarding { ContentView() }
#endif
    }

#if DEBUG
    private func runMarketingCaptureIfRequested() async {
        let arguments = ProcessInfo.processInfo.arguments
        guard arguments.contains("--marketing-capture") else { return }
        do {
#if os(iOS)
            guard arguments.contains("--marketing-preview") else { return }
            navigationContext.selectedTab = .today
            try await Task.sleep(for: .seconds(7))
            let tabs: [AppTab] = arguments.contains("--marketing-duo-preview") ? [.page, .insights] : [.page, .insights, .customize]
            for tab in tabs {
                navigationContext.selectedTab = tab
                try await Task.sleep(for: .seconds(5))
            }
            navigationContext.selectedTab = .today
#elseif os(macOS)
            if arguments.contains("--export-store-captures") {
                try await MacStoreCapture.export(navigation: navigationContext, preview: marketingCapture)
            }
#endif
        } catch is CancellationError {
            return
        } catch {
            marketingCapture.errorMessage = error.localizedDescription
        }
    }
#endif
}
