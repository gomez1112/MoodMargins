//
//  InsightsViewModel.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/27/26.
//

import Foundation
import Observation

/// Stores the interactive state and derived data for the Insights screen.
@MainActor
@Observable
final class InsightsViewModel {
    /// The number of recent days included in range-based insight cards.
    var selectedRange = 7

    /// The latest streamed AI recap for the selected range.
    var generatedRecap: PartialGeneratedInsightRecap?

    /// A Boolean value indicating whether an AI recap is currently streaming.
    var isGeneratingRecap = false

    /// Non-blocking status copy for recap generation failures.
    var recapErrorMessage: String?

    private let recapProvider: any InsightRecapProviding
    private var recapTask: Task<Void, Never>?
    private var activeSnapshotIdentity: String?

    init(recapProvider: any InsightRecapProviding = FoundationInsightRecapProvider()) {
        self.recapProvider = recapProvider
    }

    /// Builds the summary stickers shown at the top of the Insights screen.
    ///
    /// - Parameter entries: The mood entries to summarize.
    /// - Returns: A fixed set of summary values ready for display.
    func summaryItems(for entries: [MoodEntry]) -> [InsightSummaryItem] {
        let distribution = distribution(for: entries)
        let bestMood = distribution.max { $0.count < $1.count }?.mood ?? .angry
        let topTag = tagCounts(for: entries).first?.tag ?? "calm"

        return [
            InsightSummaryItem(id: "average", title: "Average", value: String(format: "%.1f", averageMood(for: entries)), systemName: "sparkles"),
            InsightSummaryItem(id: "entries", title: "Entries", value: "\(entries.count)", systemName: "book.pages.fill"),
            InsightSummaryItem(id: "common", title: "Most common", value: bestMood.systemImage, systemName: "heart.fill"),
            InsightSummaryItem(id: "topTag", title: "Top tag", value: "#\(topTag)", systemName: "tag.fill")
        ]
    }

    /// Builds the mood trend series for the currently selected range.
    ///
    /// - Parameter entries: The mood entries to group by day.
    /// - Returns: Daily mood averages ordered from oldest to newest.
    func trendSeries(for entries: [MoodEntry]) -> [DailyMood] {
        MoodInsights.dailyAverages(entries, days: selectedRange)
    }

    /// Builds mood distribution counts for all available moods.
    ///
    /// - Parameter entries: The mood entries to count.
    /// - Returns: Mood counts in `Mood.allCases` order.
    func distribution(for entries: [MoodEntry]) -> [MoodCount] {
        MoodInsights.distribution(entries)
    }

    /// Builds the top activity list shown in the favorite margins card.
    ///
    /// - Parameter entries: The mood entries whose activities should be counted.
    /// - Returns: Up to four activity counts sorted by frequency.
    func topActivities(for entries: [MoodEntry]) -> [ActivityCount] {
        MoodInsights.topActivities(entries, limit: 4)
    }

    /// Returns a stable identifier for refreshing the generated recap from SwiftUI task modifiers.
    func recapRefreshID(for entries: [MoodEntry]) -> String {
        let snapshot = InsightRecapSnapshotBuilder.snapshot(from: entries, selectedRange: selectedRange)
        return snapshot.identity
    }

    /// Starts or skips AI recap generation for the current entry range.
    func refreshGeneratedRecap(from entries: [MoodEntry]) {
        let snapshot = InsightRecapSnapshotBuilder.snapshot(from: entries, selectedRange: selectedRange)
        guard snapshot.identity != activeSnapshotIdentity else { return }

        activeSnapshotIdentity = snapshot.identity
        recapTask?.cancel()
        recapErrorMessage = nil

        guard snapshot.canGenerate else {
            generatedRecap = .fallback(for: selectedRange)
            isGeneratingRecap = false
            return
        }

        generatedRecap = .empty
        isGeneratingRecap = true

        recapTask = Task { [recapProvider] in
            do {
                try await recapProvider.generateRecap(for: snapshot) { partial in
                    generatedRecap = partial
                }
            } catch {
                guard !Task.isCancelled else { return }
                generatedRecap = nil
                recapErrorMessage = FoundationModelsErrorPresenter.message(for: error)
                activeSnapshotIdentity = nil
            }

            guard !Task.isCancelled else { return }
            isGeneratingRecap = false
        }
    }

    func cancelGeneratedRecap() {
        recapTask?.cancel()
        recapTask = nil
        isGeneratingRecap = false
    }

    private func averageMood(for entries: [MoodEntry]) -> Double {
        MoodInsights.averageMood(entries)
    }

    private func tagCounts(for entries: [MoodEntry]) -> [(tag: String, count: Int)] {
        var counts: [String: Int] = [:]
        for entry in entries {
            for tag in entry.tags {
                counts[tag, default: 0] += 1
            }
        }

        return counts.sorted { $0.value > $1.value }
            .map { ($0.key, $0.value) }
    }
}
