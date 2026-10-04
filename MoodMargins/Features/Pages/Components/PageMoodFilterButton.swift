import SwiftUI

struct PageMoodFilterButton: View {
    var title: String
    var mood: Mood?
    var selectedMood: Mood?
    var action: () -> Void
    private var isSelected: Bool { selectedMood == mood }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if isSelected { Image(systemName: "checkmark") }
                Text(title)
            }
            .font(.caption.bold())
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(minHeight: 44)
            .background((mood?.tint ?? PastelTheme.ink).opacity(isSelected ? 0.22 : 0.10), in: Capsule())
            .foregroundStyle(PastelTheme.ink)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}
