//
//  InsightsView.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/27/26.
//

import EZSwiftData
import SwiftData
import SwiftUI

struct InsightsView: View {
    @Query(sort: \MoodEntry.date, order: .reverse) private var entries: [MoodEntry]

    @State private var viewModel = InsightsViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            AdaptiveContentWidth(maximumWidth: 1120) {
                VStack(alignment: .leading, spacing: 22) {
                    Header()
                    SummaryStack(summaryItems: viewModel.summaryItems(for: entries))
                    TrendCard(selectedRange: $viewModel.selectedRange, series: viewModel.trendSeries(for: entries))
                    InsightPairs(
                        distribution: viewModel.distribution(for: entries),
                        topActivities: viewModel.topActivities(for: entries)
                    )
                    ReflectionPairs(
                        selectedRange: viewModel.selectedRange,
                        generatedRecap: viewModel.generatedRecap,
                        isGeneratingRecap: viewModel.isGeneratingRecap,
                        recapErrorMessage: viewModel.recapErrorMessage
                    )
                }
                .padding(22)
            }
        }
        .safeAreaPadding(.bottom, 88)
        .background(PastelTheme.background.ignoresSafeArea())
        .navigationTitle("")
        .toolbar(.hidden, for: .navigationBar)
        .task(id: viewModel.recapRefreshID(for: entries)) {
            viewModel.refreshGeneratedRecap(from: entries)
        }
        .onDisappear {
            viewModel.cancelGeneratedRecap()
        }
    }
}

#Preview(traits: .dev(AppPreviewConfig.self)) {
    NavigationStack {
        InsightsView()
    }
}
