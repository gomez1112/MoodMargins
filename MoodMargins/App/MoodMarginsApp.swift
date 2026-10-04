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
    @State private var navigationContext = NavigationContext()
    @State private var modelPreferences = FoundationModelPreferences()
    @State private var purchases = PurchaseStore()
    @State private var themes = ThemePreferences()
    private let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainerFactory.create(MoodEntry.self, Activity.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }
    var body: some Scene {
        WindowGroup {
            MoodMarginsOnboarding {
                ContentView()
            }
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
        .environment(\.diaryPalette, themes.effectiveTheme(access: purchases.entitlements).palette)
        .modelContainer(container)
    }
}
