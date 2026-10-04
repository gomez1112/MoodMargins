import SwiftUI

struct CalendarStickerButton: View {
    @ScaledMetric(relativeTo: .caption) private var width = 72.0
    var entry: MoodEntry
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(entry.date, format: .dateTime.month(.abbreviated).day())
                    .font(.caption.bold())
                    .foregroundStyle(PastelTheme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                MoodLottieIcon(mood: entry.mood, size: 26)
                    .accessibilityHidden(true)
            }
            .padding(10)
            .frame(width: min(width, 160))
            .background(entry.mood.tint.opacity(0.16), in: .rect(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? PastelTheme.ink : .clear, lineWidth: 2)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(entry.date.formatted(date: .complete, time: .omitted))
        .accessibilityValue(entry.mood.title)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}
