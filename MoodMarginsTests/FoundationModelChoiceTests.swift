import Foundation
import FoundationModels
import Testing
@testable import MoodMargins

@Suite("Foundation model selection")
@MainActor
struct FoundationModelChoiceTests {
    @Test("PCC is the default and turning it off persists across launches")
    func persistsSelection() throws {
        let suite = "MoodMargins.ModelChoiceTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let preferences = FoundationModelPreferences(defaults: defaults)
        #expect(preferences.choice == .privateCloudCompute)
        #expect(preferences.usesPrivateCloudCompute)
        preferences.usesPrivateCloudCompute = false
        #expect(FoundationModelPreferences(defaults: defaults).choice == .onDevice)
        preferences.usesPrivateCloudCompute = true
        #expect(FoundationModelPreferences(defaults: defaults).choice == .privateCloudCompute)
        defaults.set("unknown-model", forKey: FoundationModelPreferences.storageKey)
        #expect(FoundationModelPreferences(defaults: defaults).choice == .privateCloudCompute)
    }

    @Test("Recap identity tracks the chosen model and note-only edits")
    func requestIdentity() {
        let entry = TestFactory.entry(date: Date(), mood: .wink, note: "A quiet morning", tags: ["rest"])
        let local = InsightRecapSnapshotBuilder.snapshot(from: [entry], selectedRange: 7)
        let cloud = InsightRecapSnapshotBuilder.snapshot(from: [entry], selectedRange: 7, modelChoice: .privateCloudCompute)
        #expect(local.modelChoice == .onDevice)
        #expect(cloud.modelChoice == .privateCloudCompute)
        #expect(local.identity != cloud.identity)
        entry.note = "Dinner with friends"
        let edited = InsightRecapSnapshotBuilder.snapshot(from: [entry], selectedRange: 7)
        #expect(edited.identity != local.identity)
        let model = InsightsViewModel()
        let originalRefreshID = model.recapRefreshID(for: [entry])
        model.retryGeneratedRecap()
        #expect(model.recapRefreshID(for: [entry]) != originalRefreshID)
    }

    @Test("Cloud failures show connection, quota, and service recovery instructions")
    func cloudErrors() {
        let network = PrivateCloudComputeLanguageModel.Error.networkFailure(.init(debugDescription: "internal network details"))
        let quota = PrivateCloudComputeLanguageModel.Error.quotaLimitReached(.init(debugDescription: "internal quota details"))
        let service = PrivateCloudComputeLanguageModel.Error.serviceUnavailable(.init(debugDescription: "internal service details"))
        #expect(FoundationModelsErrorPresenter.message(for: network).contains("internet connection"))
        #expect(FoundationModelsErrorPresenter.message(for: quota).contains("limit reached"))
        #expect(FoundationModelsErrorPresenter.message(for: service).contains("temporarily unavailable"))
        #expect(!FoundationModelsErrorPresenter.message(for: network).contains("internal"))
    }
}
