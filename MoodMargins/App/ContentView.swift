//
//  ContentView.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/21/26.
//

import SwiftData
import SwiftUI
import EZSwiftData

struct ContentView: View {
    @Environment(NavigationContext.self) private var navigationContext

    var body: some View {
        @Bindable var navigationContext = navigationContext

        TabView(selection: $navigationContext.selectedTab) {
            Tab(AppTab.today.title, systemImage: AppTab.today.systemImage, value: AppTab.today) {
                NavigationStack(path: $navigationContext.todayPath) {
                    TodayView()
                        .navigationDestination(for: AppScreen.self) { screen in
                            screen.destination
                        }
                }
            }
            .customizationID(AppTab.today.rawValue)
            
            Tab(AppTab.page.title, systemImage: AppTab.page.systemImage, value: AppTab.page) {
                NavigationStack(path: $navigationContext.pagePath) {
                    PageView()
                        .navigationDestination(for: AppScreen.self) { screen in
                            screen.destination
                        }
                }
            }
            .customizationID(AppTab.page.rawValue)
            Tab(AppTab.insights.title, systemImage: AppTab.insights.systemImage, value: AppTab.insights) {
                NavigationStack(path: $navigationContext.insightsPath) {
                    InsightsView()
                        .navigationDestination(for: AppScreen.self) { screen in
                            screen.destination
                        }
                }
            }
            .customizationID(AppTab.insights.rawValue)
        }
        .tabViewStyle(.sidebarAdaptable)
        .tint(PastelTheme.ink)
        .sheet(item: $navigationContext.presentedSheet) { sheet in
            NavigationStack {
                sheet.destination
            }
        }
#if os(macOS)
        // macOS presents these routes as sheets because full-screen covers are unavailable.
        .sheet(item: $navigationContext.presentedFullScreenCover) { fullScreenCover in
            NavigationStack {
                fullScreenCover.destination
            }
        }
#else
        .fullScreenCover(item: $navigationContext.presentedFullScreenCover) { fullScreenCover in
            NavigationStack {
                fullScreenCover.destination
            }
        }
#endif
    }
}

#Preview("Dev", traits: .dev(AppPreviewConfig.self, { context in
    PreviewDependencies(context: context)
})) {
    ContentView()
}
