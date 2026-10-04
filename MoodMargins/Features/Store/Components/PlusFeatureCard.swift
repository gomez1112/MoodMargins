import SwiftUI

struct PlusFeatureCard: View {
    @Environment(NavigationContext.self) private var navigationContext
    var title: String
    var message: String

    var body: some View {
        InsightPage(title: title, symbol: "sparkles", rotation: 0) {
            VStack(alignment: .leading, spacing: 14) {
                Text(message).foregroundStyle(.secondary)
                Button("Explore Plus", systemImage: "sparkles") {
                    navigationContext.selectTab(.customize)
                }
                .buttonStyle(.bordered)
            }
        }
    }
}
