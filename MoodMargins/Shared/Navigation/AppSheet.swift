//
//  AppSheet.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/27/26.
//

import SwiftUI

/// Sheet presentations that can be triggered from anywhere in the view tree.
enum AppSheet: Identifiable, Hashable {
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
