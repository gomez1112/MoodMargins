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
    @State private var navigationContext = NavigationContext()
    @State private var modelPreferences = FoundationModelPreferences()
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
        }
        .environment(navigationContext)
        .environment(modelPreferences)
        .modelContainer(container)
    }
}
