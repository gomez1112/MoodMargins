//
//  NavigationContext.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/27/26.
//

import Observation
import SwiftUI

/// Owns per-window navigation state for tabs, stacks, and modal presentations.
@MainActor
@Observable
final class NavigationContext {
    var selectedTab: AppTab = .today
    var todayPath: [AppScreen] = []
    var pagePath: [AppScreen] = []
    var insightsPath: [AppScreen] = []
    var presentedSheet: AppSheet?
    var presentedFullScreenCover: AppFullScreenCover?

    func selectTab(_ tab: AppTab) {
        selectedTab = tab
    }

    func show(_ screen: AppScreen) {
        selectedTab = screen.tab
    }

    func push(_ screen: AppScreen, on tab: AppTab? = nil) {
        switch tab ?? selectedTab {
        case .today:
            todayPath.append(screen)
            case .page:
                pagePath.append(screen)
        case .insights:
            insightsPath.append(screen)
        }
    }

    func popToRoot(in tab: AppTab? = nil) {
        switch tab ?? selectedTab {
        case .today:
            todayPath.removeAll()
            case .page:
                pagePath.removeAll()
        case .insights:
            insightsPath.removeAll()
        }
    }

    func presentSheet(_ sheet: AppSheet) {
        presentedSheet = sheet
    }

    func dismissSheet() {
        presentedSheet = nil
    }

    func presentFullScreenCover(_ fullScreenCover: AppFullScreenCover) {
        presentedFullScreenCover = fullScreenCover
    }

    func dismissFullScreenCover() {
        presentedFullScreenCover = nil
    }
}
