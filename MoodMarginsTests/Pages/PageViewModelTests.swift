//
//  PageViewModelTests.swift
//  MoodMarginsTests
//
//  Created by Gerard Gomez on 6/28/26.
//

import SwiftData
@testable import MoodMargins
import XCTest

@MainActor
final class PageViewModelTests: XCTestCase {
    override func tearDown() async throws {
        await MainActor.run { TestFactory.resetInMemoryModelContainers() }
        try await super.tearDown()
    }

    func testSelectedTagsPreserveGroupedOrderAndAppendCustomTags() {
        let viewModel = PageViewModel()
        viewModel.tags = ["zine", "cozy", "calm", "apple", "work", "outdoors"]

        XCTAssertEqual(viewModel.selectedTagList, ["calm", "work", "outdoors", "cozy", "apple", "zine"])
    }

    func testLoadingEntryCopiesEditableValues() {
        let entry = TestFactory.entry(date: TestFactory.date(daysAgo: 2), mood: .mourn, note: "Loaded note", tags: ["calm", "work"])
        let viewModel = PageViewModel()

        viewModel.loadEntry(entry)

        XCTAssertEqual(viewModel.selectedDate, entry.date)
        XCTAssertEqual(viewModel.selectedMood, .mourn)
        XCTAssertEqual(viewModel.note, "Loaded note")
        XCTAssertEqual(viewModel.tags, ["calm", "work"])
        XCTAssertEqual(viewModel.selectedEntryID, entry.id)
    }

    func testSaveInsertsNewEntryWhenNoPageMatches() throws {
        let context = try TestFactory.inMemoryModelContext()
        let viewModel = PageViewModel()
        viewModel.selectedDate = TestFactory.date(daysAgo: 4)
        viewModel.selectedMood = .wink
        viewModel.note = "New page"
        viewModel.tags = ["work", "custom"]

        viewModel.saveCurrentPage(entries: [], modelContext: context)

        let savedEntries = try context.fetch(FetchDescriptor<MoodEntry>())
        let savedEntry = try XCTUnwrap(savedEntries.first)
        XCTAssertEqual(savedEntries.count, 1)
        XCTAssertEqual(savedEntry.date, viewModel.selectedDate)
        XCTAssertEqual(savedEntry.mood, .wink)
        XCTAssertEqual(savedEntry.note, "New page")
        XCTAssertEqual(savedEntry.tags, ["work", "custom"])
        XCTAssertEqual(savedEntry.sleepQuality, 3)
        XCTAssertEqual(savedEntry.energyLevel, 3)
        XCTAssertEqual(viewModel.selectedEntryID, savedEntry.id)
    }

    func testSaveUpdatesSelectedEntryBeforeConsideringSameDayEntry() throws {
        let context = try TestFactory.inMemoryModelContext()
        let selectedEntry = TestFactory.entry(date: TestFactory.date(daysAgo: 3), mood: .angry, note: "Selected", tags: ["tired"])
        let sameDayEntry = TestFactory.entry(date: TestFactory.date(daysAgo: 0), mood: .sad, note: "Same day", tags: ["calm"])
        context.insert(selectedEntry)
        context.insert(sameDayEntry)

        let viewModel = PageViewModel()
        viewModel.selectedEntryID = selectedEntry.id
        viewModel.selectedDate = sameDayEntry.date
        viewModel.selectedMood = .laughing
        viewModel.note = "Updated selected"
        viewModel.tags = ["outdoors"]

        viewModel.saveCurrentPage(entries: [sameDayEntry, selectedEntry], modelContext: context)

        let savedEntries = try context.fetch(FetchDescriptor<MoodEntry>())
        XCTAssertEqual(savedEntries.count, 2)
        XCTAssertEqual(selectedEntry.id, viewModel.selectedEntryID)
        XCTAssertEqual(selectedEntry.date, sameDayEntry.date)
        XCTAssertEqual(selectedEntry.mood, .laughing)
        XCTAssertEqual(selectedEntry.note, "Updated selected")
        XCTAssertEqual(selectedEntry.tags, ["outdoors"])
        XCTAssertEqual(sameDayEntry.note, "Same day")
    }

    func testSaveUpdatesSameDayEntryWhenNoSelectedEntryIsSet() throws {
        let context = try TestFactory.inMemoryModelContext()
        let existingEntry = TestFactory.entry(date: TestFactory.date(daysAgo: 0), mood: .sad, note: "Before", tags: ["calm"])
        context.insert(existingEntry)

        let viewModel = PageViewModel()
        viewModel.selectedDate = existingEntry.date
        viewModel.selectedMood = .wink
        viewModel.note = "After"
        viewModel.tags = ["music", "cozy"]

        viewModel.saveCurrentPage(entries: [existingEntry], modelContext: context)

        let savedEntries = try context.fetch(FetchDescriptor<MoodEntry>())
        XCTAssertEqual(savedEntries.count, 1)
        XCTAssertEqual(viewModel.selectedEntryID, existingEntry.id)
        XCTAssertEqual(existingEntry.mood, .wink)
        XCTAssertEqual(existingEntry.note, "After")
        XCTAssertEqual(existingEntry.tags, ["music", "cozy"])
    }
}
