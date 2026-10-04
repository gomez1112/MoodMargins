import SwiftUI

struct DistributionCard: View {
    @ScaledMetric(relativeTo: .body) private var emojiSize = 34.0
    var distribution: [MoodCount]
    private var total: Int { distribution.reduce(0) { $0 + $1.count } }

    var body: some View {
        InsightPage(title: String(localized: "Mood stickers"), symbol: "face.smiling", rotation: 1) {
            VStack(alignment: .leading, spacing: 16) {
                if total == 0 {
                    Text("No moods recorded in this range.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Share of saved pages")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ForEach(distribution) { item in
                        VStack(alignment: .leading, spacing: 6) {
                            ViewThatFits(in: .horizontal) {
                                HStack {
                                    MoodLottieIcon(mood: item.mood, size: min(emojiSize, 60)).accessibilityHidden(true)
                                    Spacer(minLength: 8)
                                    countLabel(item).fixedSize()
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    MoodLottieIcon(mood: item.mood, size: min(emojiSize, 60)).accessibilityHidden(true)
                                    countLabel(item)
                                }
                            }
                            GeometryReader { proxy in
                                Capsule().fill(PastelTheme.ink.opacity(0.10))
                                    .overlay(alignment: .leading) {
                                        Capsule().fill(item.mood.tint)
                                            .frame(width: proxy.size.width * share(item))
                                    }
                            }
                            .frame(height: 8)
                            .accessibilityHidden(true)
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(item.mood.title)
                        .accessibilityValue(String(localized: "\(item.count) pages, \(share(item).formatted(.percent.precision(.fractionLength(0))))"))
                    }
                }
            }
        }
    }

    private func share(_ item: MoodCount) -> Double { Double(item.count) / Double(max(total, 1)) }

    private func countLabel(_ item: MoodCount) -> some View {
        Text("\(item.count) · \(share(item).formatted(.percent.precision(.fractionLength(0))))")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}
