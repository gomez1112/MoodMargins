import SwiftUI

enum PastelTheme {
    static let ink = Color("DiaryInk")
    static let softInk = Color("DiarySoftInk")
    static let paper = Color("DiaryPaper")
    static let blush = Color("DiaryBlush")
    static let sky = Color("DiarySky")
    static let lavenderLine = Color("DiaryRule")
    static let action = Color.indigo

    static var background: LinearGradient {
        LinearGradient(colors: [blush, sky], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static func washiColor(_ tag: String) -> Color {
        let palette: [Color] = [.pink, .purple, .mint, .orange, .blue, .teal]
        // Swift's hashValue changes between launches; a tag keeps its color here.
        let hash = tag.unicodeScalars.reduce(UInt64(0)) { ($0 &* 31) &+ UInt64($1.value) }
        return palette[Int(hash % UInt64(palette.count))]
    }
}
