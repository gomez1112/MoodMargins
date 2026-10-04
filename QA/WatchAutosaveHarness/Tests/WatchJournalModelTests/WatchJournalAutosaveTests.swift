import Foundation
import Testing
@testable import WatchJournalModel

@Suite("Watch journal autosave")
@MainActor
struct WatchJournalAutosaveTests {
    @Test("Opening or typing whitespace creates no entry; an explicit mood does")
    func blankAndMoodOnly() async throws {
        let name = "WatchAutosave-\(UUID())"
        let defaults = try #require(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }
        let journal = WatchJournalStore(defaults: defaults)
        journal.note = " \n "
        journal.saveIfChanged()
        #expect(journal.entries.isEmpty)
        journal.selectMood(.laughing)
        await journal.autosave()
        #expect(journal.entries.count == 1)
        #expect(journal.entries.first?.mood == .laughing)
        #expect(!journal.hasChanges)
    }

    @Test("Repeated edits persist in the same entry and survive reopening")
    func persistenceAndIdentity() async throws {
        let name = "WatchAutosave-\(UUID())"
        let defaults = try #require(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }
        let journal = WatchJournalStore(defaults: defaults)
        journal.note = "First thought"
        await journal.autosave()
        let id = try #require(journal.entries.first?.id)
        journal.note = "A clearer thought"
        journal.saveIfChanged()
        let reopened = WatchJournalStore(defaults: defaults)
        #expect(reopened.entries.count == 1)
        #expect(reopened.entries.first?.id == id)
        #expect(reopened.note == "A clearer thought")
    }

    @Test("Cancelled debounce retains typing until an immediate lifecycle save")
    func cancellation() async throws {
        let name = "WatchAutosave-\(UUID())"
        let defaults = try #require(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }
        let journal = WatchJournalStore(defaults: defaults)
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
        let journal = WatchJournalStore(defaults: defaults)
        journal.note = "A new thought"
        await journal.autosave()
        journal.saveIfChanged()
        #expect(journal.errorMessage != nil)
        #expect(defaults.data(forKey: "watchJournalEntries") == original)
    }
}
