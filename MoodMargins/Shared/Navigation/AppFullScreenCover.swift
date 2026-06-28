//
//  AppFullScreenCover.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/27/26.
//

import SwiftUI

/// Full-screen presentations that can be triggered from anywhere in the view tree.
enum AppFullScreenCover: Identifiable, Hashable {
    case today
    case insights

    var id: Self { self }

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
