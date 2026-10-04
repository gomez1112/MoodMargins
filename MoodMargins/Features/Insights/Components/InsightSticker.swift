import SwiftUI

struct InsightSticker: View {
    @Environment(\.diaryPalette) private var palette
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var minimumHeight = 125.0
    var title: String
    var value: String
    var systemName: String
    var mood: Mood? = nil
    @ScaledMetric(relativeTo: .title3) private var emojiSize = 54.0

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let mood {
                MoodLottieIcon(mood: mood, size: min(emojiSize, 90))
                    .accessibilityHidden(true)
            } else {
                Image(systemName: systemName)
                    .font(.body)
                    .foregroundStyle(palette.ink)
                    .accessibilityHidden(true)
                Text(value)
                    .font(.system(.title3, design: .rounded).bold())
                    .foregroundStyle(palette.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: dynamicTypeSize.isAccessibilitySize ? 0 : minimumHeight, alignment: .topLeading)
        .background(palette.paper, in: .rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 5, y: 3)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(value)
    }
}
