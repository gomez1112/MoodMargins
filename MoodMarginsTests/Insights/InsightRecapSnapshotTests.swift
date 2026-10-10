//
//  InsightRecapSnapshotTests.swift
//  MoodMarginsTests
//
//  Created by Gerard Gomez on 6/28/26.
//

import Foundation
import Testing
@testable import MoodMargins

@Suite("Insight recap snapshots", .serialized)
@MainActor
struct InsightRecapSnapshotTests {
    @MainActor private final class CountingRecapProvider: InsightRecapProviding {
        var calls = 0
        func generateRecap(for snapshot: InsightRecapSnapshot, onPartial: @MainActor @Sendable (PartialGeneratedInsightRecap) -> Void) async throws {
            calls += 1
        }
    }

    @Test("A free journal never sends a recap request and clears prior results")
    func noRecapWithoutPlus() async {
        let provider = CountingRecapProvider()
        let model = InsightsViewModel(recapProvider: provider)
        let entries = [TestFactory.entry(date: TestFactory.date(daysAgo: 1)), TestFactory.entry(date: TestFactory.date(daysAgo: 0))]
        await model.refreshGeneratedRecap(from: entries, hasPlus: true)
        #expect(provider.calls == 1)
        await model.refreshGeneratedRecap(from: entries, using: .privateCloudCompute, hasPlus: false)
        #expect(provider.calls == 1)
        #expect(model.generatedRecap == nil)
        #expect(model.recapErrorMessage == nil)
        #expect(!model.isGeneratingRecap)
    }

    private struct FailingRecapProvider: InsightRecapProviding {
        func generateRecap(
            for snapshot: InsightRecapSnapshot,
            onPartial: @MainActor @Sendable (PartialGeneratedInsightRecap) -> Void
        ) async throws {
            throw FoundationModelsAppError.modelUnavailable("Apple Intelligence is still preparing.")
        }
    }

    @Test("Recap generation failure stops loading and shows the error state")
    func recapGenerationFailureStopsLoading() async {
        let entries = [
            TestFactory.entry(date: TestFactory.date(daysAgo: 1), mood: .wink, note: "Walked outside.", tags: ["calm"]),
            TestFactory.entry(date: TestFactory.date(daysAgo: 0), mood: .laughing, note: "Dinner felt easy.", tags: ["family"])
        ]
        let viewModel = InsightsViewModel(recapProvider: FailingRecapProvider())

        await viewModel.refreshGeneratedRecap(from: entries, hasPlus: true)

        #expect(viewModel.isGeneratingRecap == false)
        #expect(viewModel.generatedRecap == nil)
        #expect(viewModel.recapErrorMessage == "Apple Intelligence is still preparing.")
    }

    private struct CancelledRecapProvider: InsightRecapProviding {
        func generateRecap(
            for snapshot: InsightRecapSnapshot,
            onPartial: @MainActor @Sendable (PartialGeneratedInsightRecap) -> Void
        ) async throws {
            throw CancellationError()
        }
    }

    @Test("Cancelled recap generation stops loading without presenting an error")
    func cancellationIsNormal() async {
        let entries = [
            TestFactory.entry(date: TestFactory.date(daysAgo: 1), note: "Yesterday"),
            TestFactory.entry(date: TestFactory.date(daysAgo: 0), note: "Today")
        ]
        let model = InsightsViewModel(recapProvider: CancelledRecapProvider())
        await model.refreshGeneratedRecap(from: entries, hasPlus: true)
        #expect(!model.isGeneratingRecap)
        #expect(model.recapErrorMessage == nil)
        #expect(model.generatedRecap == nil)
    }

    @Test("Snapshot filters entries to the selected range and summarizes top tags")
    func snapshotFiltersRangeAndSummarizesTags() {
        let entries = [
            TestFactory.entry(date: TestFactory.date(daysAgo: 8), mood: .angry, note: "Outside range", tags: ["old"]),
            TestFactory.entry(date: TestFactory.date(daysAgo: 2), mood: .wink, note: "Walked outside and read.", tags: ["calm", "outdoors"], activities: [TestFactory.activity(title: "Reading")]),
            TestFactory.entry(date: TestFactory.date(daysAgo: 0), mood: .laughing, note: "Dinner felt easy.", tags: ["calm", "family"], activities: [TestFactory.activity(title: "Food")])
        ]

        let snapshot = InsightRecapSnapshotBuilder.snapshot(from: entries, selectedRange: 7, now: TestFactory.date(daysAgo: 0))

        #expect(snapshot.entryCount == 2)
        #expect(snapshot.averageMood == 4.5)
        #expect(snapshot.topTags == ["calm", "family", "outdoors"])
        #expect(snapshot.topActivities == ["food", "reading"])
        #expect(snapshot.canGenerate)
    }

    @Test("Snapshot detects sparse ranges that should not generate")
    func sparseSnapshotDoesNotGenerate() {
        let entries = [
            TestFactory.entry(date: TestFactory.date(daysAgo: 0), mood: .sad, note: "One note", tags: ["tired"])
        ]

        let snapshot = InsightRecapSnapshotBuilder.snapshot(from: entries, selectedRange: 7, now: TestFactory.date(daysAgo: 0))

        #expect(snapshot.entryCount == 1)
        #expect(snapshot.canGenerate == false)
        #expect(snapshot.trend == .unknown)
    }

    @Test("Snapshot prompt includes bounded note excerpts and non-diagnostic instruction")
    func snapshotPromptIsBoundedAndSafe() {
        let longNote = String(repeating: "soft morning ", count: 30)
        let entries = [
            TestFactory.entry(date: TestFactory.date(daysAgo: 1), mood: .mourn, note: longNote, tags: ["rest"]),
            TestFactory.entry(date: TestFactory.date(daysAgo: 0), mood: .wink, note: "Felt steadier today", tags: ["calm"])
        ]

        let snapshot = InsightRecapSnapshotBuilder.snapshot(from: entries, selectedRange: 7, now: TestFactory.date(daysAgo: 0))

        #expect(snapshot.entries.first?.noteExcerpt.count ?? 0 <= 140)
        #expect(snapshot.promptText.contains("Avoid diagnosis"))
        #expect(snapshot.promptText.contains("Range: 7 days"))
    }
}
