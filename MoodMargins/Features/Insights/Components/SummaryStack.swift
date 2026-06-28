//
//  SummaryStack.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/27/26.
//

import SwiftUI

struct SummaryStack: View {
    let summaryItems: [InsightSummaryItem]

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) {
                ForEach(summaryItems) { item in
                    InsightSticker(title: item.title, value: item.value, systemName: item.systemName)
                        .frame(minWidth: 140, maxWidth: .infinity, alignment: .leading)
                }
            }

            AdaptiveCardGrid(items: summaryItems, minimumCardWidth: 140, maximumCardWidth: 260, spacing: 12) { item in
                InsightSticker(title: item.title, value: item.value, systemName: item.systemName)
            }
        }
    }
}

#Preview {
    SummaryStack(summaryItems: InsightsViewModel().summaryItems(for: MoodEntry.samples))
}
