//
//  MoodMarginsApp.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/21/26.
//

import SwiftUI
import SwiftData
import EZSwiftData

@main
struct MoodMarginsApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var navigationContext: NavigationContext
    @State private var modelPreferences = FoundationModelPreferences()
    @State private var purchases = PurchaseStore()
    @State private var themes = ThemePreferences()
#if DEBUG
    @State private var marketingCapture: MarketingCaptureState
#endif
    private let container: ModelContainer
    
    init() {
#if DEBUG
        let capture = MarketingCaptureState()
#endif
        do {
#if DEBUG
            if ProcessInfo.processInfo.arguments.contains("--marketing-capture"), let preview = capture.container {
                container = preview
            } else {
                container = try ModelContainerFactory.create(MoodEntry.self, Activity.self)
            }
#else
            container = try ModelContainerFactory.create(MoodEntry.self, Activity.self)
#endif
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
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
#if DEBUG
        _marketingCapture = State(initialValue: capture)
#endif
    }
    var body: some Scene {
        WindowGroup {
            rootContent
#if DEBUG
            .id(marketingCapture.isEnabled)
            .environment(marketingCapture)
            .preferredColorScheme(marketingCapture.appearance)
            .transformEnvironment(\.locale) { locale in
                if let captureLocale = marketingCapture.locale { locale = captureLocale }
            }
#if os(iOS)
            .task {
                let arguments = ProcessInfo.processInfo.arguments
                guard arguments.contains("--marketing-capture"), arguments.contains("--marketing-preview") else { return }
                do {
                    // Viewing intervals for a live screen recording of the
                    // actual app. Fictional data remains in its isolated store.
                    navigationContext.selectedTab = .today
                    try await Task.sleep(for: .seconds(7))
                    for tab in [AppTab.page, .insights, .customize] {
                        navigationContext.selectedTab = tab
                        try await Task.sleep(for: .seconds(5))
                    }
                    navigationContext.selectedTab = .today
                } catch is CancellationError {
                    return
                } catch {
                    marketingCapture.errorMessage = error.localizedDescription
                }
            }
#endif
#if os(macOS)
            .task {
                let arguments = ProcessInfo.processInfo.arguments
                guard arguments.contains("--marketing-capture"), arguments.contains("--export-store-captures") else { return }
                do {
                    try await MacStoreCapture.export(navigation: navigationContext, preview: marketingCapture)
                } catch is CancellationError {
                    return
                } catch {
                    marketingCapture.errorMessage = error.localizedDescription
                    print("STORE_CAPTURE_FAILED: \(error)")
                }
            }
#endif
#endif
            .task { await purchases.observeTransactions() }
            .task { await purchases.observeSubscriptionStatus() }
            .task(id: scenePhase) {
                if scenePhase == .active { await purchases.refreshEntitlements() }
            }
        }
        .environment(navigationContext)
        .environment(modelPreferences)
        .environment(purchases)
        .environment(themes)
        .environment(\.diaryPalette, activePalette)
        .modelContainer(activeContainer)
    }

    @ViewBuilder
    private var rootContent: some View {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--marketing-capture") {
            ContentView()
        } else {
            MoodMarginsOnboarding { ContentView() }
        }
#else
        MoodMarginsOnboarding { ContentView() }
#endif
    }

    private var activeContainer: ModelContainer {
#if DEBUG
        marketingCapture.container ?? container
#else
        container
#endif
    }

    private var activePalette: DiaryPalette {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--marketing-capture") {
            return DiaryTheme.pastel.palette
        }
#endif
        return themes.effectiveTheme(access: purchases.entitlements).palette
    }
}
