import SwiftUI

enum PastelTheme {
    static let ink = Color(red: 0.45, green: 0.40, blue: 0.55)
    static let softInk = Color(red: 0.58, green: 0.52, blue: 0.66)
    static let paper = Color(red: 0.99, green: 0.97, blue: 0.94)
    static let blush = Color(red: 1.0, green: 0.93, blue: 0.95)
    static let sky = Color(red: 0.93, green: 0.95, blue: 1.0)
    static let lavenderLine = Color(red: 0.80, green: 0.78, blue: 0.85)

    static var background: LinearGradient {
        LinearGradient(colors: [blush, sky], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static func washiColor(_ tag: String) -> Color {
        let palette: [Color] = [.pink, .purple, .mint, .orange, .blue, .teal]
        return palette[abs(tag.hashValue) % palette.count]
    }
}
