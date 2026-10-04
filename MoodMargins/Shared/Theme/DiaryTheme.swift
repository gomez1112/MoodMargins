import Foundation

enum DiaryTheme: String, CaseIterable, Identifiable, Sendable {
    case pastel
    case botanical
    case coastal
    case sunset

    var id: Self { self }

    var title: String {
        switch self {
        case .pastel: String(localized: "Pastel")
        case .botanical: String(localized: "Botanical")
        case .coastal: String(localized: "Coastal")
        case .sunset: String(localized: "Sunset")
        }
    }

    var description: String {
        switch self {
        case .pastel: String(localized: "The original blush pages and lavender ink.")
        case .botanical: String(localized: "Sage pages, forest ink, and a quiet garden feel.")
        case .coastal: String(localized: "Sea-glass blue, sandy paper, and deep ocean ink.")
        case .sunset: String(localized: "Peach skies, warm paper, and terracotta accents.")
        }
    }

    var symbol: String {
        switch self {
        case .pastel: "paintpalette"
        case .botanical: "leaf"
        case .coastal: "water.waves"
        case .sunset: "sun.horizon"
        }
    }

    var product: StoreProduct? {
        switch self {
        case .pastel: nil
        case .botanical: .botanical
        case .coastal: .coastal
        case .sunset: .sunset
        }
    }

    var palette: DiaryPalette {
        DiaryPalette(assetPrefix: self == .pastel ? "Diary" : rawValue.capitalized)
    }
}
