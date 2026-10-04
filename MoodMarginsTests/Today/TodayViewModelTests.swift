//
//  TodayViewModelTests.swift
//  MoodMarginsTests
//
//  Created by Gerard Gomez on 6/28/26.
//

import SwiftData
@testable import MoodMargins
import XCTest

@MainActor
final class TodayViewModelTests: XCTestCase {
    struct StatusScenario {
        let name: String
        let pageSaved: Bool
        let note: String
        let savedNote: String
        let selectedMood: Mood
        let savedMood: Mood
        let selectedTags: Set<String>
        let savedTags: Set<String>
        let expectedStatus: String
        let expectedButtonTitle: String
        let expectedHasPendingChanges: Bool
    }

    override func tearDown() async throws {
        await MainActor.run { TestFactory.resetInMemoryModelContainers() }
        try await super.tearDown()
    }

    func testStatusAndSaveButton() {
        let scenarios = [
            StatusScenario(
                name: "saved page without pending changes",
                pageSaved: true,
                note: "A steady day.",
                savedNote: "A steady day.",
                selectedMood: .wink,
                savedMood: .wink,
                selectedTags: ["calm"],
                savedTags: ["calm"],
                expectedStatus: "Today's page saved",
                expectedButtonTitle: "Saved",
                expectedHasPendingChanges: false
            ),
            StatusScenario(
                name: "empty unsaved draft",
                pageSaved: false,
                note: "  \n",
                savedNote: "",
                selectedMood: .laughing,
                savedMood: .laughing,
                selectedTags: [],
                savedTags: [],
                expectedStatus: "Dear diary…",
                expectedButtonTitle: "Save",
                expectedHasPendingChanges: true
            ),
            StatusScenario(
                name: "note changed",
                pageSaved: true,
                note: "A changed note.",
                savedNote: "Original note.",
                selectedMood: .sad,
                savedMood: .sad,
                selectedTags: [],
                savedTags: [],
                expectedStatus: "Unsaved changes",
                expectedButtonTitle: "Save",
                expectedHasPendingChanges: true
            ),
            StatusScenario(
                name: "tags changed",
                pageSaved: true,
                note: "Same note.",
                savedNote: "Same note.",
                selectedMood: .mourn,
                savedMood: .mourn,
                selectedTags: ["work"],
                savedTags: [],
                expectedStatus: "Unsaved changes",
                expectedButtonTitle: "Save",
                expectedHasPendingChanges: true
            )
        ]

        for scenario in scenarios {
            let viewModel = TodayViewModel()
            viewModel.pageSaved = scenario.pageSaved
            viewModel.note = scenario.note
            viewModel.savedNote = scenario.savedNote
            viewModel.selectedMood = scenario.selectedMood
            viewModel.savedMood = scenario.savedMood
            viewModel.selectedTags = scenario.selectedTags
            viewModel.savedTags = scenario.savedTags

            XCTAssertEqual(viewModel.statusText, scenario.expectedStatus, scenario.name)
            XCTAssertEqual(viewModel.saveButtonTitle, scenario.expectedButtonTitle, scenario.name)
            XCTAssertEqual(viewModel.hasPendingChanges, scenario.expectedHasPendingChanges, scenario.name)
        }
    }

    func testSelectedTagsFollowSuggestionOrder() {
        let viewModel = TodayViewModel()
        viewModel.selectedTags = ["outdoors", "calm", "unknown", "work", "rest", "grateful"]

        XCTAssertEqual(viewModel.selectedTagList, ["grateful", "calm", "work", "rest", "outdoors", "unknown"])
    }

    func testHiddenSelectedTagCountClampsAtZero() {
        let viewModel = TodayViewModel()

        viewModel.selectedTags = ["unknown"]
        XCTAssertEqual(viewModel.selectedTagList, ["unknown"])
        XCTAssertEqual(viewModel.hiddenSelectedTagCount, 0)

        viewModel.selectedTags = ["outdoors", "calm", "work", "rest", "grateful"]
        XCTAssertEqual(viewModel.hiddenSelectedTagCount, 1)
    }

    func testLoadTodayPrefersTodaysEntry() {
        let olderEntry = TestFactory.entry(date: TestFactory.date(daysAgo: 2), mood: .sad, note: "Older", tags: ["work"])
        let todayEntry = TestFactory.entry(date: TestFactory.date(daysAgo: 0), mood: .laughing, note: "Today", tags: ["calm", "rest"])
        let viewModel = TodayViewModel()

        viewModel.loadTodayIfNeeded(from: [olderEntry, todayEntry])

        XCTAssertEqual(viewModel.selectedMood, .laughing)
        XCTAssertEqual(viewModel.note, "Today")
        XCTAssertEqual(viewModel.selectedTags, ["calm", "rest"])
        XCTAssertEqual(viewModel.savedMood, .laughing)
        XCTAssertEqual(viewModel.savedNote, "Today")
        XCTAssertEqual(viewModel.savedTags, ["calm", "rest"])
        XCTAssertTrue(viewModel.pageSaved)
        XCTAssertTrue(viewModel.didLoadToday)
    }

    func testLoadTodayStartsEmptyWhenOnlyHistoricalEntriesExist() {
        let firstEntry = TestFactory.entry(date: TestFactory.date(daysAgo: 3), mood: .mourn, note: "First", tags: ["social"])
        let secondEntry = TestFactory.entry(date: TestFactory.date(daysAgo: 5), mood: .angry, note: "Second", tags: ["tired"])
        let viewModel = TodayViewModel()

        viewModel.loadTodayIfNeeded(from: [firstEntry, secondEntry])

        XCTAssertEqual(viewModel.selectedMood, .laughing)
        XCTAssertEqual(viewModel.note, "")
        XCTAssertEqual(viewModel.selectedTags, [])
        XCTAssertFalse(viewModel.pageSaved)
    }

    func testRefreshPreservesAnUnsavedDraft() {
        let initialEntry = TestFactory.entry(date: TestFactory.date(daysAgo: 0), mood: .sad, note: "Initial", tags: ["tired"])
        let laterEntry = TestFactory.entry(date: TestFactory.date(daysAgo: 0), mood: .laughing, note: "Later", tags: ["grateful"])
        let viewModel = TodayViewModel()

        viewModel.loadTodayIfNeeded(from: [initialEntry])
        viewModel.note = "User draft"
        viewModel.loadTodayIfNeeded(from: [laterEntry])

        XCTAssertEqual(viewModel.selectedMood, .sad)
        XCTAssertEqual(viewModel.note, "User draft")
        XCTAssertEqual(viewModel.selectedTags, ["tired"])
    }

    func testNoteChangeMarksPageUnsaved() {
        let viewModel = TodayViewModel()
        viewModel.note = "Saved note"
        viewModel.savedNote = "Saved note"
        viewModel.pageSaved = true

        viewModel.markPageUnsavedIfNoteChanged()
        XCTAssertTrue(viewModel.pageSaved)

        viewModel.note = "Changed note"
        viewModel.markPageUnsavedIfNoteChanged()
        XCTAssertFalse(viewModel.pageSaved)
    }

    func testSaveInsertsNewEntry() throws {
        let context = try TestFactory.inMemoryModelContext()
        let viewModel = TodayViewModel()
        viewModel.selectedMood = .wink
        viewModel.note = "Inserted entry"
        viewModel.selectedTags = ["rest", "work", "unknown"]

        viewModel.saveTodayPage(entries: [], modelContext: context)

        let savedEntries = try context.fetch(FetchDescriptor<MoodEntry>())
        let savedEntry = try XCTUnwrap(savedEntries.first)
        XCTAssertEqual(savedEntries.count, 1)
        XCTAssertEqual(savedEntry.mood, .wink)
        XCTAssertEqual(savedEntry.note, "Inserted entry")
        XCTAssertEqual(savedEntry.tags, ["work", "rest", "unknown"])
        XCTAssertEqual(savedEntry.sleepQuality, 3)
        XCTAssertEqual(savedEntry.energyLevel, 3)
        XCTAssertTrue(viewModel.pageSaved)
        XCTAssertFalse(viewModel.hasPendingChanges)
    }

    func testSelectGeneratedTagAddsTagAndRemovesSuggestion() {
        let viewModel = TodayViewModel()
        viewModel.pageSaved = true
        viewModel.generatedTagSuggestions = ["#Morning", "family"]

        viewModel.selectGeneratedTag("#Morning")

        XCTAssertEqual(viewModel.selectedTags, ["morning"])
        XCTAssertEqual(viewModel.generatedTagSuggestions, ["family"])
        XCTAssertFalse(viewModel.pageSaved)
    }

    func testTagNormalizerCleansSuggestions() {
        let tags = MoodTagNormalizer.normalizedTags(
            ["#Calm", " calm ", "Work!", "two words", ""],
            excluding: ["work"],
            limit: 3
        )

        XCTAssertEqual(tags, ["calm", "two words"])
    }

    func testFallbackTagSuggestionsProduceVisibleTags() {
        let request = MoodTaggingRequest(
            note: "I felt scattered this morning after a difficult work meeting, but a quiet walk outside and cooking dinner helped me feel calmer and more grateful by the evening.",
            selectedTags: ["grateful", "tired", "social", "work"]
        )

        let tags = MoodTagFallbackSuggester.suggestions(for: request)

        XCTAssertEqual(tags, ["food", "calm", "outdoors", "stress"])
    }

    func testSaveUpdatesExistingEntry() throws {
        let context = try TestFactory.inMemoryModelContext()
        let existingEntry = TestFactory.entry(date: TestFactory.date(daysAgo: 0), mood: .angry, note: "Before", tags: ["tired"])
        context.insert(existingEntry)

        let viewModel = TodayViewModel()
        viewModel.selectedMood = .laughing
        viewModel.note = "After"
        viewModel.selectedTags = ["calm", "outdoors"]

        viewModel.saveTodayPage(entries: [existingEntry], modelContext: context)

        let savedEntries = try context.fetch(FetchDescriptor<MoodEntry>())
        let savedEntry = try XCTUnwrap(savedEntries.first)
        XCTAssertEqual(savedEntries.count, 1)
        XCTAssertEqual(savedEntry.id, existingEntry.id)
        XCTAssertEqual(savedEntry.mood, .laughing)
        XCTAssertEqual(savedEntry.note, "After")
        XCTAssertEqual(savedEntry.tags, ["calm", "outdoors"])
        XCTAssertTrue(viewModel.pageSaved)
        XCTAssertFalse(viewModel.hasPendingChanges)
    }
}
