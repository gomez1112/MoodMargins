import SwiftUI

struct PlusFeatureCard: View {
    @Environment(\.diaryPalette) private var palette
    @Environment(NavigationContext.self) private var navigationContext
    var title: String
    var message: String

    var body: some View {
        InsightPage(title: title, symbol: "sparkles", rotation: 0) {
            VStack(alignment: .leading, spacing: 14) {
                Text(message).foregroundStyle(palette.softInk)
                Button("Explore Plus", systemImage: "sparkles") {
                    navigationContext.presentSheet(.plus)
                }
                .buttonStyle(.bordered)
            }
        }
    }
}
