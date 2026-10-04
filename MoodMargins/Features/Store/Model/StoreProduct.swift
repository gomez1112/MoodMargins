import Foundation

enum StoreProduct: String, CaseIterable, Identifiable, Sendable {
    case weekly = "com.transfinite.MoodMargins.plus.weekly"
    case monthly = "com.transfinite.MoodMargins.plus.monthly"
    case yearly = "com.transfinite.MoodMargins.plus.yearly"
    case botanical = "com.transfinite.MoodMargins.theme.botanical"
    case coastal = "com.transfinite.MoodMargins.theme.coastal"
    case sunset = "com.transfinite.MoodMargins.theme.sunset"

    var id: String { rawValue }

    var isSubscription: Bool {
        switch self {
        case .weekly, .monthly, .yearly: true
        case .botanical, .coastal, .sunset: false
        }
    }

    var title: String {
        switch self {
        case .weekly: String(localized: "Weekly")
        case .monthly: String(localized: "Monthly")
        case .yearly: String(localized: "Yearly")
        case .botanical: DiaryTheme.botanical.title
        case .coastal: DiaryTheme.coastal.title
        case .sunset: DiaryTheme.sunset.title
        }
    }

    nonisolated static var subscriptions: [Self] { [.weekly, .monthly, .yearly] }
}
