import SwiftUI

struct WashiTagButton: View {
    var tag: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Toggle(isOn: Binding { isSelected } set: { _ in action() }) {
            HStack(spacing: 6) {
                if isSelected { Image(systemName: "checkmark") }
                Text("#\(tag)")
            }
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(minHeight: 44)
            .background(PastelTheme.washiColor(tag).opacity(0.18), in: Capsule())
            .foregroundStyle(.primary)
        }
        .toggleStyle(.button)
        .buttonStyle(.plain)
        .accessibilityLabel("\(tag) tag")
    }
}
