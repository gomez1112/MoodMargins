import SwiftUI

/// Colorful paper cards share the main diary's palette. System navigation
/// retains watchOS's dark canvas and semantic foreground colors.
enum WatchDiaryStyle {
    static var ink: Color { Color("DiaryInk") }
    static var paper: Color { Color("DiaryPaper") }
    static var action: Color { Color("DiaryAction") }
    static var rule: Color { Color("DiaryRule") }
    static var blush: Color { Color("DiaryBlush") }
    static var sky: Color { Color("DiarySky") }

    static var canvas: LinearGradient {
        LinearGradient(
            colors: [.black, ink.opacity(0.85), Color.indigo.opacity(0.65)],
            startPoint: .top,
            endPoint: .bottomTrailing
        )
    }

    static func moodPaper(_ mood: Mood) -> LinearGradient {
        let color: Color = switch mood {
        case .angry, .wink: blush
        case .sad, .laughing: sky
        case .mourn: rule.opacity(0.45)
        }
        return LinearGradient(colors: [paper, color], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
