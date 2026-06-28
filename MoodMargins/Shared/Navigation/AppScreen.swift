//
//  AppScreen.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/27/26.
//

import SwiftUI

/// Screens that can be addressed by app-level navigation.
enum AppScreen: Hashable {
    case today
    case insights

    var tab: AppTab {
        switch self {
        case .today:
            .today
        case .insights:
            .insights
        }
    }

    @ViewBuilder
    var destination: some View {
        switch self {
        case .today:
            TodayView()
        case .insights:
            InsightsView()
        }
    }
}
