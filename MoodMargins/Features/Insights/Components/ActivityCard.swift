//
//  ActivityCard.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/27/26.
//

import SwiftUI

struct ActivityCard: View {
    let topActivities: [ActivityCount]

    var body: some View {
        InsightPage(title: String(localized: "Favorite margins"), symbol: "tag.fill", rotation: -0.7) {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(topActivities) { item in
                    HStack(spacing: 12) {
                        Image(systemName: item.activity.symbol)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(PastelTheme.ink)
                            .frame(width: 30, height: 30)
                            .background(.pink.opacity(0.16), in: RoundedRectangle(cornerRadius: 10))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.activity.title)
                                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                                .foregroundStyle(PastelTheme.ink)
                            Text("appeared in \(item.count) pages")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }
                }
            }
        }
    }
}

#Preview {
    ActivityCard(topActivities: InsightsViewModel().topActivities(for: MoodEntry.samples))
}
