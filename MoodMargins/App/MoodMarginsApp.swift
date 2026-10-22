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
#if DEBUG
        _marketingCapture = State(initialValue: capture)
#endif
    }
    var body: some Scene {
        WindowGroup {
            JournalSceneRoot()
#if DEBUG
                .id(marketingCapture.isEnabled)
                .environment(marketingCapture)
#if !os(visionOS)
                .preferredColorScheme(marketingCapture.appearance)
#endif
                .transformEnvironment(\.locale) { locale in
                    if let captureLocale = marketingCapture.locale { locale = captureLocale }
                }
                .transformEnvironment(\.layoutDirection) { direction in
                    if let locale = marketingCapture.locale {
                        direction = locale.language.languageCode?.identifier == "ar" ? .rightToLeft : .leftToRight
                    }
                }
#endif
        }
        .environment(modelPreferences)
        .environment(purchases)
        .environment(themes)
        .environment(\.diaryPalette, activePalette)
        .modelContainer(activeContainer)
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
