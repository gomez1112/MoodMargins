//
//  InsightPairs.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/27/26.
//

import SwiftUI

struct InsightPairs: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let distribution: [MoodCount]
    let topActivities: [ActivityCount]

    var body: some View {
        ViewThatFits(in: .horizontal) {
            if !dynamicTypeSize.isAccessibilitySize {
                HStack(alignment: .top, spacing: 22) {
                    DistributionCard(distribution: distribution)
                        .frame(minWidth: 320, maxWidth: .infinity, alignment: .topLeading)
                    ActivityCard(topActivities: topActivities)
                        .frame(minWidth: 320, maxWidth: .infinity, alignment: .topLeading)
                }
            }
            VStack(alignment: .leading, spacing: 22) {
                DistributionCard(distribution: distribution)
                ActivityCard(topActivities: topActivities)
            }
        }
    }
}
