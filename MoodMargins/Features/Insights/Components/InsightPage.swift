import SwiftUI

/// Keeps content aligned; the small piece of tape carries the diary decoration.
struct InsightPage<Content: View>: View {
    @Environment(\.diaryPalette) private var palette
    var title: String
    var symbol: String
    var rotation: Double
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(title, systemImage: symbol)
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(palette.ink)
                .accessibilityAddTraits(.isHeader)
            content()
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(palette.paper, in: .rect(cornerRadius: 18))
        .overlay(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 5)
                .fill(.purple.opacity(0.18))
                .frame(width: 66, height: 18)
                .rotationEffect(.degrees(rotation - 5))
                .offset(x: -24, y: -9)
                .accessibilityHidden(true)
                .allowsHitTesting(false)
        }
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }
}
