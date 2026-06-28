//
//  InsightPairs.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/27/26.
//

import SwiftUI

struct InsightPairs: View {
    let distribution: [MoodCount]
    let topActivities: [ActivityCount]

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: 22) {
                DistributionCard(distribution: distribution)
                    .frame(minWidth: 320, maxWidth: .infinity, alignment: .topLeading)
                ActivityCard(topActivities: topActivities)
                    .frame(minWidth: 320, maxWidth: .infinity, alignment: .topLeading)
            }

            VStack(alignment: .leading, spacing: 22) {
                DistributionCard(distribution: distribution)
                ActivityCard(topActivities: topActivities)
            }
        }
    }
}

#Preview {
    let viewModel = InsightsViewModel()

    InsightPairs(
        distribution: viewModel.distribution(for: MoodEntry.samples),
        topActivities: viewModel.topActivities(for: MoodEntry.samples)
    )
}
