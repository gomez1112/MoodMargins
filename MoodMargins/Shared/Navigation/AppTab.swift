//
//  AppTab.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/27/26.
//

import Foundation

/// The top-level destinations shown in the app tab interface.
enum AppTab: String, CaseIterable, Identifiable, Hashable {
    case today
    case page
    case insights
    case customize

    var id: Self { self }

    var title: String {
        switch self {
        case .today:
            String(localized: "Today")
        case .page:
            String(localized: "Page")
        case .insights:
            String(localized: "Insights")
        case .customize:
            String(localized: "Customize")
        }
    }

    var systemImage: String {
        switch self {
        case .today:
            "sun.max"
            case .page:
            "pencil"
        case .insights:
            "chart.xyaxis.line"
        case .customize:
            "paintpalette"
        }
    }
}
