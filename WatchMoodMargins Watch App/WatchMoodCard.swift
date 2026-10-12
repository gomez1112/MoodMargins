import SwiftUI

/// A paper page large enough to read and tap on the smallest supported Watch.
struct WatchMoodCard: View {
    @ScaledMetric(relativeTo: .body) private var emblemSize = 68.0
    var mood: Mood
    var title: String
    var animates = true
    var showsDisclosure = false
    var isSelected = false
    var isCompact = false

    var body: some View {
        VStack(spacing: 6) {
            WatchMoodAnimation(mood: mood, size: min(emblemSize, 92) * (isCompact ? 0.85 : 1), animates: animates)
            HStack(spacing: 6) {
                Text(title)
                    .font(isCompact ? .headline : .title3.bold())
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                if showsDisclosure {
                    Image(systemName: "chevron.forward")
                        .font(.caption.bold())
                        .accessibilityHidden(true)
                }
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption.bold())
                        .accessibilityHidden(true)
                }
            }
        }
        .foregroundStyle(WatchDiaryStyle.ink)
        .padding(.horizontal, 12)
        .padding(.vertical, isCompact ? 10 : 14)
        .frame(maxWidth: .infinity)
        .background(WatchDiaryStyle.moodPaper(mood), in: .rect(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(WatchDiaryStyle.rule.opacity(0.7))
        }
        .contentShape(.rect(cornerRadius: 24))
    }
}
