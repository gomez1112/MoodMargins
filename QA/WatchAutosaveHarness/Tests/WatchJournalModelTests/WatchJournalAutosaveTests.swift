import Foundation
import Testing
import SwiftData
@testable import WatchJournalModel

@Suite("Watch journal autosave")
@MainActor
struct WatchJournalAutosaveTests {
    @Test("Opening or typing whitespace creates no entry; an explicit mood does")
    func blankAndMoodOnly() async throws {
        let name = "WatchAutosave-\(UUID())"
        let defaults = try #require(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }
        let container = try makeContainer()
        let journal = WatchJournalStore(container: container, defaults: defaults)
        #expect(!journal.hasSelectedMood)
        journal.note = " \n "
        journal.saveIfChanged()
        #expect(journal.entries.isEmpty)
        journal.selectMood(.laughing)
        #expect(journal.hasSelectedMood)
        await journal.autosave()
        #expect(journal.entries.count == 1)
        #expect(journal.entries.first?.mood == .laughing)
        #expect(!journal.hasChanges)
        #expect(journal.hasSelectedMood)
    }

    @Test("Repeated edits persist in the same entry and survive reopening")
    func persistenceAndIdentity() async throws {
        let name = "WatchAutosave-\(UUID())"
        let defaults = try #require(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }
        let container = try makeContainer()
        let journal = WatchJournalStore(container: container, defaults: defaults)
        journal.note = "First thought"
        await journal.autosave()
        let id = try #require(journal.entries.first?.id)
        journal.note = "A clearer thought"
        journal.saveIfChanged()
        let reopened = WatchJournalStore(container: container, defaults: defaults)
        #expect(reopened.entries.count == 1)
        #expect(reopened.entries.first?.id == id)
        #expect(reopened.note == "A clearer thought")
    }

    @Test("Cancelled debounce retains typing until an immediate lifecycle save")
    func cancellation() async throws {
        let name = "WatchAutosave-\(UUID())"
        let defaults = try #require(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }
        let container = try makeContainer()
        let journal = WatchJournalStore(container: container, defaults: defaults)
        journal.note = "Keep this thought"
        let pending = Task { await journal.autosave() }
        pending.cancel()
        await pending.value
        #expect(journal.entries.isEmpty)
        #expect(journal.errorMessage == nil)
        #expect(journal.note == "Keep this thought")
        journal.saveIfChanged()
        #expect(journal.entries.first?.note == "Keep this thought")
    }

    @Test("Unreadable stored data is reported and never replaced by autosave")
    func corruptStorage() async throws {
        let name = "WatchAutosave-\(UUID())"
        let defaults = try #require(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }
        let original = Data("unreadable journal".utf8)
        defaults.set(original, forKey: "watchJournalEntries")
        let container = try makeContainer()
        let journal = WatchJournalStore(container: container, defaults: defaults)
        journal.note = "A new thought"
        await journal.autosave()
        journal.saveIfChanged()
        #expect(journal.errorMessage != nil)
        #expect(defaults.data(forKey: "watchJournalEntries") == original)
    }
    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([MoodEntry.self, Activity.self])
        let configuration = ModelConfiguration("WatchTests-\(UUID())", schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    @Test("Legacy pages migrate once, preserving IDs and distinct phone notes")
    func migrateLegacyPages() throws {
        let name = "WatchMigration-\(UUID())"
        let defaults = try #require(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }
        let container = try makeContainer()
        let phone = MoodEntry(date: Date(), mood: .sad, note: "Phone page", tags: ["family"], sleepQuality: 4, energyLevel: 2)
        container.mainContext.insert(phone)
        try container.mainContext.save()
        let old = WatchJournalEntry(id: UUID(), date: Date(), mood: .wink, note: "Previously local Watch page")
        let data = try JSONEncoder().encode([old, old])
        defaults.set(data, forKey: "watchJournalEntries")
        let journal = WatchJournalStore(container: container, defaults: defaults)
        #expect(journal.entries.count == 2)
        #expect(journal.entries.contains { $0.id == old.id && $0.note == old.note })
        #expect(phone.note == "Phone page")
        #expect(defaults.data(forKey: "watchJournalEntries") == nil)
        let reopened = WatchJournalStore(container: container, defaults: defaults)
        #expect(reopened.entries.count == 2)
    }

    @Test("A mood-only edit preserves newer phone text, tags, and wellbeing details")
    func moodOnlyPreservesPhoneFields() throws {
        let name = "WatchMerge-\(UUID())"
        let defaults = try #require(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }
        let container = try makeContainer()
        let phone = MoodEntry(date: Date(), mood: .sad, note: "Original note", tags: ["family"], sleepQuality: 4, energyLevel: 2)
        container.mainContext.insert(phone)
        try container.mainContext.save()
        let journal = WatchJournalStore(container: container, defaults: defaults)
        journal.selectMood(.wink)
        phone.note = "A newer phone note"
        try container.mainContext.save()
        journal.saveIfChanged()
        #expect(phone.mood == .wink)
        #expect(phone.note == "A newer phone note")
        #expect(phone.tags == ["family"])
        #expect(phone.sleepQuality == 4)
        #expect(phone.energyLevel == 2)
        #expect(journal.note == phone.note)
        #expect(try container.mainContext.fetchCount(FetchDescriptor<MoodEntry>()) == 1)
    }

    @Test("Imported updates refresh a clean editor while unfinished writing stays intact")
    func importDuringEditing() throws {
        let name = "WatchRefresh-\(UUID())"
        let defaults = try #require(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }
        let container = try makeContainer()
        let journal = WatchJournalStore(container: container, defaults: defaults)
        let phone = MoodEntry(date: Date(), mood: .sad, note: "Phone note", tags: ["family"], sleepQuality: 4, energyLevel: 2)
        container.mainContext.insert(phone)
        try container.mainContext.save()
        journal.synchronize(from: [WatchJournalEntry(phone)])
        #expect(journal.selectedMood == .sad)
        #expect(journal.note == "Phone note")
        journal.note = "Unfinished Watch draft"
        phone.note = "Another phone edit"
        phone.mood = .mourn
        try container.mainContext.save()
        journal.synchronize(from: [WatchJournalEntry(phone)])
        #expect(journal.note == "Unfinished Watch draft")
        journal.saveIfChanged()
        #expect(phone.note == "Unfinished Watch draft")
        #expect(phone.mood == .mourn)
        #expect(journal.selectedMood == .mourn)
    }

    @Test("An imported deletion clears a clean editor without recreating the page")
    func importedDeletion() throws {
        let name = "WatchDeletion-\(UUID())"
        let defaults = try #require(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }
        let container = try makeContainer()
        let phone = MoodEntry(date: Date(), mood: .wink, note: "Saved", tags: [], sleepQuality: 3, energyLevel: 3)
        container.mainContext.insert(phone)
        try container.mainContext.save()
        let journal = WatchJournalStore(container: container, defaults: defaults)
        container.mainContext.delete(phone)
        try container.mainContext.save()
        journal.synchronize(from: [])
        journal.saveIfChanged()
        #expect(journal.note.isEmpty)
        #expect(!journal.hasSelectedMood)
        #expect(try container.mainContext.fetchCount(FetchDescriptor<MoodEntry>()) == 0)
    }

}
