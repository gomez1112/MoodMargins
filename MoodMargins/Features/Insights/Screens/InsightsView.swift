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
    @Environment(\.diaryPalette) private var palette
    @Environment(FoundationModelPreferences.self) private var modelPreferences
    @Environment(PurchaseStore.self) private var purchases
    @Query(sort: \MoodEntry.date, order: .reverse) private var entries: [MoodEntry]

    @State private var viewModel = InsightsViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            AdaptiveContentWidth(maximumWidth: 1120) {
                VStack(alignment: .leading, spacing: 22) {
                    InsightHeader(selectedRange: $viewModel.selectedRange)
                    SummaryStack(summaryItems: viewModel.summaryItems(for: entries))
                    TrendCard(selectedRange: viewModel.selectedRange, series: viewModel.trendSeries(for: entries))
                    InsightPairs(
                        distribution: viewModel.distribution(for: entries),
                        topActivities: viewModel.topActivities(for: entries)
                    )
                    ReflectionPairs(
                        hasPlus: purchases.entitlements.hasPlus,
                        pattern: viewModel.pattern(for: entries),
                        selectedRange: viewModel.selectedRange,
                        generatedRecap: viewModel.generatedRecap,
                        isGeneratingRecap: viewModel.isGeneratingRecap,
                        recapErrorMessage: viewModel.recapErrorMessage,
                        retry: viewModel.retryGeneratedRecap
                    )
                }
                .padding(22)
            }
        }
        .safeAreaPadding(.bottom, 16)
        .background(palette.background.ignoresSafeArea())
        .navigationTitle("")
#if !os(macOS)
        .toolbar(.hidden, for: .navigationBar)
#endif
        .task(id: "\(purchases.entitlements.hasPlus):\(viewModel.recapRefreshID(for: entries, using: modelPreferences.choice))") {
            await viewModel.refreshGeneratedRecap(from: entries, using: modelPreferences.choice, hasPlus: purchases.entitlements.hasPlus)
        }
    }
}
