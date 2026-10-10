import SwiftUI

struct MiniDiaryPage: View {
    @Environment(\.diaryPalette) private var palette
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var minimumHeight = 180.0
    var entry: MoodEntry
    var showsTime = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ViewThatFits(in: .horizontal) {
                HStack {
                    MoodLottieIcon(mood: entry.mood, size: 30)
                        .accessibilityHidden(true)
                    Spacer(minLength: 8)
                    dateLabel
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.mood.title).font(.caption.bold())
                    dateLabel
                }
            }
            Text(entry.note.isEmpty ? String(localized: "A mood check-in") : entry.note)
                .font(.system(.body, design: .serif))
                .foregroundStyle(.primary)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 5 : 3)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            Text(entry.tags.prefix(2).map { "#\($0)" }.joined(separator: " · "))
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: dynamicTypeSize.isAccessibilitySize ? 0 : minimumHeight, alignment: .topLeading)
        .background(palette.paper, in: .rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 5, y: 3)
        .accessibilityElement(children: .combine)
        .accessibilityValue(entry.mood.title)
    }

    private var dateLabel: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(entry.date, format: .dateTime.month(.abbreviated).day())
            if showsTime {
                Text(entry.date, format: .dateTime.hour().minute())
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .fixedSize(horizontal: false, vertical: true)
    }
}
