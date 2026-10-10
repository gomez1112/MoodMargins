//
//  ActivityCard.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/27/26.
//

import SwiftUI

struct ActivityCard: View {
    @Environment(\.diaryPalette) private var palette
    let topActivities: [ActivityCount]

    var body: some View {
        InsightPage(title: String(localized: "Favorite margins"), symbol: "tag.fill", rotation: -0.7) {
            VStack(alignment: .leading, spacing: 12) {
                if topActivities.isEmpty {
                    Text("No activities recorded in this range.")
                        .foregroundStyle(.secondary)
                }
                ForEach(topActivities) { item in
                    HStack(spacing: 12) {
                        Image(systemName: item.activity.symbol)
                            .font(.body)
                            .foregroundStyle(palette.ink)
                            .padding(8)
                            .background(.pink.opacity(0.16), in: RoundedRectangle(cornerRadius: 10))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.activity.title)
                                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                                .foregroundStyle(palette.ink)
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
