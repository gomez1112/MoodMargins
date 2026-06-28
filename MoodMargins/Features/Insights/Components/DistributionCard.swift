//
//  DistributionCard.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/27/26.
//

import SwiftUI

struct DistributionCard: View {
    let distribution: [MoodCount]

    private var maxCount: Int {
        max(distribution.map(\.count).max() ?? 1, 1)
    }

    var body: some View {
        InsightPage(title: String(localized: "Mood stickers"), symbol: "face.smiling", rotation: 1.0) {
            VStack(spacing: 12) {
                ForEach(distribution) { item in
                    HStack(spacing: 10) {
                        MoodLottieIcon(mood: item.mood, size: 34)

                        GeometryReader { proxy in
                            RoundedRectangle(cornerRadius: 9)
                                .fill(item.mood.tint.opacity(0.18))
                                .overlay(alignment: .leading) {
                                    if item.count > 0 {
                                        RoundedRectangle(cornerRadius: 9)
                                            .fill(item.mood.tint.opacity(0.70))
                                            .frame(width: proxy.size.width * CGFloat(item.count) / CGFloat(maxCount))
                                    }
                                }
                        }
                        .frame(height: 18)

                        Text("\(item.count)")
                            .font(.system(.caption, design: .rounded).weight(.semibold))
                            .foregroundStyle(PastelTheme.softInk)
                            .frame(width: 24, alignment: .trailing)
                    }
                }
            }
        }
    }
}

#Preview {
    DistributionCard(distribution: InsightsViewModel().distribution(for: MoodEntry.samples))
}
