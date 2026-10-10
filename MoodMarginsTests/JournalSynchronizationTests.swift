import Foundation
import SwiftData
import Testing
@testable import MoodMargins

@Suite("Journal UI regressions")
@MainActor
struct JournalSynchronizationTests {
    @Test("A changed saved note invalidates its old generated suggestions")
    func changedNoteClearsSuggestions() {
        let entry = TestFactory.entry(date: Date(), mood: .wink, note: "A walk outdoors")
        let editor = TodayViewModel()
        editor.loadTodayIfNeeded(from: [entry])
        editor.generatedTagSuggestions = ["outdoors"]
        editor.tagSuggestionError = "Previous error"
        entry.note = "A busy day at work"
        editor.loadTodayIfNeeded(from: [entry])
        #expect(editor.note == entry.note)
        #expect(editor.generatedTagSuggestions.isEmpty)
        #expect(editor.tagSuggestionError == nil)
    }

    @Test("Saved tag changes remove selected suggestions and preserve the rest")
    func changedTagsPreserveSuggestions() {
        let entry = TestFactory.entry(date: Date(), mood: .wink, note: "A walk with family")
        let editor = TodayViewModel()
        editor.loadTodayIfNeeded(from: [entry])
        editor.generatedTagSuggestions = ["family", "outdoors"]
        entry.tags = ["family"]
        editor.loadTodayIfNeeded(from: [entry])
        #expect(editor.generatedTagSuggestions == ["outdoors"])
        #expect(editor.selectedTags == ["family"])
    }

    @Test("Today refreshes a clean editor after a Page edit and preserves a draft")
    func todayRefresh() {
        let entry = TestFactory.entry(date: Date(), mood: .wink, note: "Original", tags: ["family"])
        let editor = TodayViewModel()
        editor.loadTodayIfNeeded(from: [entry])
        entry.note = "Edited in Pages"
        entry.mood = .sad
        entry.tags = ["calm"]
        editor.loadTodayIfNeeded(from: [entry])
        #expect(editor.note == "Edited in Pages")
        #expect(editor.selectedMood == .sad)
        #expect(editor.selectedTags == ["calm"])
        #expect(!editor.hasPendingChanges)
        editor.note = "Unsaved draft"
        entry.note = "Another saved edit"
        editor.loadTodayIfNeeded(from: [entry])
        #expect(editor.note == "Unsaved draft")
        #expect(editor.hasPendingChanges)
    }

    @Test("Deleting today's page clears a clean editor")
    func deletedToday() {
        let entry = TestFactory.entry(date: Date(), mood: .sad, note: "Saved", tags: ["work"])
        let editor = TodayViewModel()
        editor.loadTodayIfNeeded(from: [entry])
        editor.generatedTagSuggestions = ["busy"]
        editor.tagSuggestionError = "Previous error"
        editor.loadTodayIfNeeded(from: [])
        #expect(editor.note.isEmpty)
        #expect(editor.selectedTags.isEmpty)
        #expect(!editor.pageSaved)
        #expect(editor.generatedTagSuggestions.isEmpty)
        #expect(editor.tagSuggestionError == nil)
    }

    @Test("Page loads today's saved entry and synchronizes clean changes")
    func pageRefresh() {
        let entry = TestFactory.entry(date: Date(), mood: .wink, note: "Saved", tags: ["family"])
        let editor = PageViewModel()
        editor.synchronize(from: [entry])
        #expect(editor.selectedEntryID == entry.id)
        #expect(editor.note == "Saved")
        #expect(editor.selectedMood == .wink)
        entry.note = "Edited in Today"
        editor.synchronize(from: [entry])
        #expect(editor.note == "Edited in Today")
        #expect(!editor.hasUnsavedChanges)
        editor.note = "My draft"
        entry.note = "New saved note"
        editor.synchronize(from: [entry])
        #expect(editor.note == "My draft")
        #expect(editor.hasUnsavedChanges)
    }

    @Test("Page deletion removes the stale selection")
    func deletedPage() {
        let entry = TestFactory.entry(date: Date(), mood: .sad, note: "Saved", tags: ["work"])
        let editor = PageViewModel()
        editor.synchronize(from: [entry])
        editor.synchronize(from: [])
        #expect(editor.selectedEntryID == nil)
        #expect(editor.note.isEmpty)
        #expect(editor.tags.isEmpty)
        #expect(!editor.hasUnsavedChanges)
    }

    @Test("Initial Page synchronization does not replace an existing entry on save")
    func initialPageSave() throws {
        let schema = Schema([MoodEntry.self, Activity.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)
        let entry = TestFactory.entry(date: Date(), mood: .sad, note: "Keep this note", tags: ["calm"])
        context.insert(entry)
        try context.save()
        let editor = PageViewModel()
        editor.synchronize(from: [entry])
        editor.saveCurrentPage(entries: [entry], modelContext: context)
        let saved = try context.fetch(FetchDescriptor<MoodEntry>())
        #expect(saved.count == 1)
        #expect(saved.first?.note == "Keep this note")
        #expect(saved.first?.mood == .sad)
        #expect(editor.saveErrorMessage == nil)
    }

    @Test("Search matches accents, mixed case, tags, and surrounding whitespace")
    func search() {
        let entry = TestFactory.entry(date: Date(), mood: .wink, note: "A quiet café", tags: ["Family"])
        let editor = PageViewModel()
        for query in [" CAFE ", "family", "WINK"] {
            editor.searchText = query
            #expect(editor.filteredEntries(from: [entry]).count == 1)
        }
        editor.moodFilter = .sad
        #expect(editor.filteredEntries(from: [entry]).isEmpty)
    }
}
