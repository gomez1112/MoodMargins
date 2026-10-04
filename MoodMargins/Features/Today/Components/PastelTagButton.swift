import SwiftUI

struct PastelTagButton: View {
    var tag: String
    @Binding var selectedTags: Set<String>
    @Binding var pageSaved: Bool

    var body: some View {
        Toggle(isOn: Binding {
            selectedTags.contains(tag)
        } set: { selected in
            if selected { selectedTags.insert(tag) } else { selectedTags.remove(tag) }
            pageSaved = false
        }) {
            HStack(spacing: 6) {
                if selectedTags.contains(tag) { Image(systemName: "checkmark") }
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
