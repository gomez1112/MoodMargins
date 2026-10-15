import Foundation
import SwiftData

/// Uses the exact journal models and private CloudKit database used by the main app.
@MainActor
final class WatchJournalPersistence {
    private let container: ModelContainer
    private let defaults: UserDefaults
    private let legacyKey = "watchJournalEntries"

    init(container: ModelContainer, defaults: UserDefaults) {
        self.container = container
        self.defaults = defaults
    }

    func load() throws -> [WatchJournalEntry] {
        try migrateLegacyEntries()
        return try models().map(WatchJournalEntry.init)
    }

    func save(id: UUID?, date: Date, mood: Mood?, note: String?) throws -> WatchJournalEntry {
        let context = container.mainContext
        let entries = try models()
        let existing = entries.first { $0.id == id }
            ?? entries.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
        let entry = existing ?? MoodEntry(date: date, mood: mood ?? .laughing, tags: [], sleepQuality: 3, energyLevel: 3)
        if entry.modelContext == nil { context.insert(entry) }
        // Update only edited fields: a mood-only check-in must never erase a phone note or its tags.
        if let mood { entry.mood = mood }
        if let note { entry.note = note }
        do {
            try context.save()
            return WatchJournalEntry(entry)
        } catch {
            context.rollback()
            throw error
        }
    }

    private func models() throws -> [MoodEntry] {
        try container.mainContext.fetch(FetchDescriptor<MoodEntry>(sortBy: [SortDescriptor(\.date, order: .reverse)]))
    }

    private func migrateLegacyEntries() throws {
        guard let data = defaults.data(forKey: legacyKey) else { return }
        let legacy = try JSONDecoder().decode([WatchJournalEntry].self, from: data)
        let existingIDs = Set(try models().map(\.id))
        let context = container.mainContext
        var importedIDs = existingIDs
        for old in legacy where importedIDs.insert(old.id).inserted {
            // Preserve separate historical Watch pages and their identity rather than overwrite phone text.
            let entry = MoodEntry(date: old.date, mood: old.mood, note: old.note, tags: [], sleepQuality: 3, energyLevel: 3)
            entry.id = old.id
            context.insert(entry)
        }
        do {
            try context.save()
            // Remove the old copy only after the new store is durable, so deletions cannot resurrect it later.
            defaults.removeObject(forKey: legacyKey)
        } catch {
            context.rollback()
            throw error
        }
    }
}
