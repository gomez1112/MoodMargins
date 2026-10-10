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
    @Environment(\.diaryPalette) private var palette
    @Environment(NavigationContext.self) private var navigationContext
    @Environment(PurchaseStore.self) private var purchases

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
            Tab(AppTab.customize.title, systemImage: AppTab.customize.systemImage, value: AppTab.customize) {
                NavigationStack(path: $navigationContext.customizePath) {
                    StoreView()
                        .navigationDestination(for: AppScreen.self) { screen in
                            screen.destination
                        }
                }
            }
            .customizationID(AppTab.customize.rawValue)
        }
        .tabViewStyle(.sidebarAdaptable)
        .tint(palette.ink)
        // Purchase feedback belongs to the active Plus sheet while it is presented.
        .alert("Purchases", isPresented: Binding {
            purchases.isShowingPurchaseMessage && navigationContext.presentedSheet != .plus
        } set: { if !$0 { purchases.isShowingPurchaseMessage = false } }) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(purchases.purchaseMessage ?? "")
        }
        .sheet(item: $navigationContext.presentedSheet) { sheet in
            if sheet == .plus {
                PlusSubscriptionView()
            } else {
                NavigationStack {
                    sheet.destination
                }
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
