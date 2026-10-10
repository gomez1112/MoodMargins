import Foundation
import SwiftData
import Testing
@testable import MoodMargins

@Suite("Journal autosave")
@MainActor
struct JournalAutosaveTests {
    private func store() throws -> ModelContainer {
        let schema = Schema([MoodEntry.self, Activity.self])
        let configuration = ModelConfiguration("Autosave-\(UUID())", schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    @Test("Selecting multiple generated tags survives each autosave query refresh")
    func generatedTagsSurviveAutosave() throws {
        let container = try store()
        let context = container.mainContext
        let editor = TodayViewModel()
        editor.loadTodayIfNeeded(from: [])
        editor.note = "A quiet morning with family outdoors."
        editor.generatedTagSuggestions = ["morning", "family", "outdoors"]
        editor.selectGeneratedTag("morning")
        editor.saveIfChanged(entries: [], modelContext: context)
        var saved = try context.fetch(FetchDescriptor<MoodEntry>())
        editor.loadTodayIfNeeded(from: saved)
        #expect(editor.generatedTagSuggestions == ["family", "outdoors"])
        #expect(editor.selectedTags == ["morning"])
        #expect(!editor.hasPendingChanges)

        editor.selectGeneratedTag("family")
        editor.saveIfChanged(entries: saved, modelContext: context)
        saved = try context.fetch(FetchDescriptor<MoodEntry>())
        editor.loadTodayIfNeeded(from: saved)
        #expect(saved.count == 1)
        #expect(Set(saved.first?.tags ?? []) == ["morning", "family"])
        #expect(editor.generatedTagSuggestions == ["outdoors"])
        #expect(editor.saveErrorMessage == nil)
    }

    @Test("Opening a blank editor or typing whitespace does not create a page")
    func blankEditors() throws {
        let container = try store()
        let context = container.mainContext
        let today = TodayViewModel()
        today.loadTodayIfNeeded(from: [])
        today.note = " \n "
        today.saveIfChanged(entries: [], modelContext: context)
        let pages = PageViewModel()
        pages.synchronize(from: [])
        pages.note = " \n "
        pages.saveIfChanged(entries: [], modelContext: context)
        #expect(try context.fetchCount(FetchDescriptor<MoodEntry>()) == 0)
    }

    @Test("Explicitly choosing the default mood saves a mood-only page")
    func moodOnly() async throws {
        let container = try store()
        let context = container.mainContext
        let today = TodayViewModel()
        today.loadTodayIfNeeded(from: [])
        today.selectMood(.laughing)
        await today.autosave(entries: [], modelContext: context)
        let saved = try context.fetch(FetchDescriptor<MoodEntry>())
        #expect(saved.count == 1)
        #expect(saved.first?.mood == .laughing)
        #expect(today.statusText == "Saved automatically")
    }

    @Test("A cancelled debounce retains the draft without reporting an error")
    func cancelledDebounce() async throws {
        let container = try store()
        let context = container.mainContext
        let today = TodayViewModel()
        today.loadTodayIfNeeded(from: [])
        today.note = "A thought still in progress"
        let pending = Task { await today.autosave(entries: [], modelContext: context) }
        pending.cancel()
        await pending.value
        #expect(today.note == "A thought still in progress")
        #expect(today.saveErrorMessage == nil)
        #expect(try context.fetchCount(FetchDescriptor<MoodEntry>()) == 0)
        today.saveIfChanged(entries: [], modelContext: context)
        #expect(try context.fetchCount(FetchDescriptor<MoodEntry>()) == 1)
    }

    @Test("Fast saves with a stale query update the same page")
    func staleQuery() throws {
        let container = try store()
        let context = container.mainContext
        let today = TodayViewModel()
        today.loadTodayIfNeeded(from: [])
        today.note = "First thought"
        today.saveIfChanged(entries: [], modelContext: context)
        today.note = "Second thought"
        today.saveIfChanged(entries: [], modelContext: context)
        let pages = PageViewModel()
        pages.synchronize(from: [])
        pages.note = "A page edit before the query refreshes"
        pages.saveIfChanged(entries: [], modelContext: context)
        let saved = try context.fetch(FetchDescriptor<MoodEntry>())
        #expect(saved.count == 1)
        #expect(saved.first?.note == pages.note)
    }

    @Test("Switching pages flushes typing into the original entry")
    func switchPages() throws {
        let container = try store()
        let context = container.mainContext
        let first = TestFactory.entry(date: Date(), mood: .wink, note: "Today")
        let second = TestFactory.entry(date: TestFactory.date(daysAgo: 1), mood: .sad, note: "Yesterday")
        context.insert(first)
        context.insert(second)
        try context.save()
        let pages = PageViewModel()
        pages.loadEntry(first)
        pages.note = "Typing just before switching"
        pages.selectEntry(second, entries: [first, second], modelContext: context)
        #expect(first.note == "Typing just before switching")
        #expect(second.note == "Yesterday")
        #expect(pages.selectedEntryID == second.id)
        #expect(!pages.hasUnsavedChanges)
    }

    @Test("A selected legacy entry is updated by identity even when its query is stale")
    func legacyIdentity() throws {
        let container = try store()
        let context = container.mainContext
        let first = TestFactory.entry(date: Date(), mood: .wink, note: "First")
        let second = TestFactory.entry(date: Date(), mood: .sad, note: "Second")
        context.insert(first)
        context.insert(second)
        try context.save()
        let pages = PageViewModel()
        pages.loadEntry(first)
        pages.note = "Only the selected entry"
        pages.saveIfChanged(entries: [second], modelContext: context)
        #expect(first.note == "Only the selected entry")
        #expect(second.note == "Second")
        #expect(try context.fetchCount(FetchDescriptor<MoodEntry>()) == 2)
    }

    @Test("Deleting the selected page cancels its draft instead of recreating it")
    func deleteSelectedPage() throws {
        let container = try store()
        let context = container.mainContext
        let entry = TestFactory.entry(date: Date(), mood: .sad, note: "Delete me")
        context.insert(entry)
        try context.save()
        let pages = PageViewModel()
        pages.loadEntry(entry)
        pages.note = "Typing while deleting"
        let deletedID = entry.id
        context.delete(entry)
        try context.save()
        pages.didDeleteEntry(deletedID)
        pages.saveIfChanged(entries: [], modelContext: context)
        #expect(try context.fetchCount(FetchDescriptor<MoodEntry>()) == 0)
        #expect(!pages.hasUnsavedChanges)
    }
}
