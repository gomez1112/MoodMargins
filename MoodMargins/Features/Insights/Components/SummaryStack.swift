import SwiftUI

struct SummaryStack: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    var summaryItems: [InsightSummaryItem]

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            singleColumn
        } else {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(summaryItems) { item in
                        sticker(item).frame(minWidth: 150, maxWidth: .infinity)
                    }
                }
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(summaryItems) { item in sticker(item) }
                }
                .frame(minWidth: 312)
                singleColumn
            }
        }
    }

    private var singleColumn: some View {
        VStack(spacing: 12) {
            ForEach(summaryItems) { item in sticker(item) }
        }
    }

    private func sticker(_ item: InsightSummaryItem) -> some View {
        InsightSticker(title: item.title, value: item.value, systemName: item.systemName, mood: item.mood)
    }
}
