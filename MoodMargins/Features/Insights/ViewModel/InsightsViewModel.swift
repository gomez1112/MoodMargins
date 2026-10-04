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
    private var activeSnapshotIdentity: String?
    private var recapRetryRevision = 0

    init(recapProvider: any InsightRecapProviding = FoundationInsightRecapProvider()) {
        self.recapProvider = recapProvider
    }

    /// Builds the summary stickers shown at the top of the Insights screen.
    ///
    /// - Parameter entries: The mood entries to summarize.
    /// - Returns: A fixed set of summary values ready for display.
    func summaryItems(for entries: [MoodEntry]) -> [InsightSummaryItem] {
        let included = MoodInsights.entries(entries, days: selectedRange)
        let counts = MoodInsights.distribution(included)
        let highestCount = counts.map(\.count).max() ?? 0
        let commonMoods = counts.filter { highestCount > 0 && $0.count == highestCount }
        let commonMood = commonMoods.last?.mood
        let topTag = tagCounts(for: included).first?.tag
        let overallMood = MoodInsights.overallMoodSummary(included)

        return [
            InsightSummaryItem(id: "average", title: String(localized: "Overall mood"), value: overallMood, systemName: "sparkles"),
            InsightSummaryItem(id: "entries", title: String(localized: "Entries"), value: included.count.formatted(), systemName: "book.pages.fill"),
            InsightSummaryItem(id: "common", title: String(localized: "Most common"), value: commonMood?.title ?? "—", systemName: "heart.fill", mood: commonMood),
            InsightSummaryItem(id: "topTag", title: String(localized: "Top tag"), value: topTag.map { "#\($0)" } ?? "—", systemName: "tag.fill")
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
        MoodInsights.distribution(MoodInsights.entries(entries, days: selectedRange))
    }

    /// Builds the top activity list shown in the favorite margins card.
    ///
    /// - Parameter entries: The mood entries whose activities should be counted.
    /// - Returns: Up to four activity counts sorted by frequency.
    func topActivities(for entries: [MoodEntry]) -> [ActivityCount] {
        MoodInsights.topActivities(MoodInsights.entries(entries, days: selectedRange), limit: 4)
    }

    func pattern(for entries: [MoodEntry]) -> String {
        MoodInsights.pattern(MoodInsights.entries(entries, days: selectedRange))
    }

    /// Returns a stable identifier for refreshing the generated recap from SwiftUI task modifiers.
    func recapRefreshID(for entries: [MoodEntry], using modelChoice: FoundationModelChoice = .onDevice) -> String {
        let snapshot = InsightRecapSnapshotBuilder.snapshot(from: entries, selectedRange: selectedRange, modelChoice: modelChoice)
        return "\(recapRetryRevision):\(snapshot.identity)"
    }

    /// Runs inside the view's cancellable task; an old range cannot update the new recap.
    func refreshGeneratedRecap(from entries: [MoodEntry], using modelChoice: FoundationModelChoice = .onDevice) async {
        let snapshot = InsightRecapSnapshotBuilder.snapshot(from: entries, selectedRange: selectedRange, modelChoice: modelChoice)
        guard snapshot.identity != activeSnapshotIdentity else { return }
        activeSnapshotIdentity = snapshot.identity
        recapErrorMessage = nil

        guard snapshot.canGenerate else {
            generatedRecap = .fallback(for: selectedRange)
            isGeneratingRecap = false
            return
        }

        generatedRecap = .empty
        isGeneratingRecap = true
        defer {
            if activeSnapshotIdentity == snapshot.identity {
                isGeneratingRecap = false
                if Task.isCancelled { activeSnapshotIdentity = nil }
            }
        }
        do {
            try Task.checkCancellation()
            try await recapProvider.generateRecap(for: snapshot) { partial in
                guard !Task.isCancelled, self.activeSnapshotIdentity == snapshot.identity else { return }
                self.generatedRecap = partial
            }
            try Task.checkCancellation()
        } catch is CancellationError {
            if activeSnapshotIdentity == snapshot.identity {
                activeSnapshotIdentity = nil
                generatedRecap = nil
                isGeneratingRecap = false
            }
        } catch {
            guard !Task.isCancelled, activeSnapshotIdentity == snapshot.identity else { return }
            generatedRecap = nil
            recapErrorMessage = FoundationModelsErrorPresenter.message(for: error)
            activeSnapshotIdentity = nil
            isGeneratingRecap = false
        }
    }

    func retryGeneratedRecap() {
        activeSnapshotIdentity = nil
        recapRetryRevision += 1
    }

    private func tagCounts(for entries: [MoodEntry]) -> [(tag: String, count: Int)] {
        var counts: [String: Int] = [:]
        for entry in entries {
            for tag in Set(entry.tags) {
                counts[tag, default: 0] += 1
            }
        }

        return counts.sorted { $0.value == $1.value ? $0.key < $1.key : $0.value > $1.value }
            .map { ($0.key, $0.value) }
    }
}
