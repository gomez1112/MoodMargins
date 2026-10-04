import SwiftUI

struct RecentPages: View {
    @Environment(\.diaryPalette) private var palette
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .body) private var cardWidth = 210.0
    var entries: [MoodEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent pages")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(palette.ink)
                .accessibilityAddTraits(.isHeader)
            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: 16) {
                    ForEach(entries) { entry in
                        MiniDiaryPage(entry: entry)
                            .frame(width: min(cardWidth, 340))
                            .scrollTransition(axis: .horizontal) { [reduceMotion] content, phase in
                                content
                                    .opacity(reduceMotion ? 1 : 1 - min(abs(phase.value), 1) * 0.15)
                                    .offset(y: reduceMotion ? 0 : min(abs(phase.value), 1) * 8)
                            }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .contentMargins(.vertical, 8)
            .scrollTargetBehavior(.viewAligned)
        }
    }
}
