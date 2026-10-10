import SwiftUI

struct DiaryPalette {
    var assetPrefix: String

    var ink: Color { Color("\(assetPrefix)Ink") }
    var softInk: Color { Color("\(assetPrefix)SoftInk") }
    var paper: Color { Color("\(assetPrefix)Paper") }
    var blush: Color { Color("\(assetPrefix)Blush") }
    var sky: Color { Color("\(assetPrefix)Sky") }
    var lavenderLine: Color { Color("\(assetPrefix)Rule") }
    var action: Color { Color("\(assetPrefix)Action") }

    var background: LinearGradient {
        LinearGradient(colors: [blush, sky], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    func washiColor(_ tag: String) -> Color {
        if assetPrefix == "Diary" { return PastelTheme.washiColor(tag) }
        let colors = [action, ink, .pink, .orange, .teal, .blue]
        let hash = tag.unicodeScalars.reduce(UInt64(0)) { ($0 &* 31) &+ UInt64($1.value) }
        return colors[Int(hash % UInt64(colors.count))]
    }
}

extension EnvironmentValues {
    @Entry var diaryPalette = DiaryTheme.pastel.palette
}
