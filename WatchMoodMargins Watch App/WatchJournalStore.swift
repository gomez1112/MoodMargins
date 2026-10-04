import Foundation
import Observation

/// A local journal. Watch pages are not advertised as synchronized with the phone.
@MainActor
@Observable
final class WatchJournalStore {
    private(set) var entries: [WatchJournalEntry] = []
    var selectedMood: Mood = .laughing
    var note = ""
    var errorMessage: String?
    private let defaults: UserDefaults
    private let storageKey = "watchJournalEntries"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: storageKey) {
            do {
                entries = try JSONDecoder().decode([WatchJournalEntry].self, from: data)
                    .sorted { $0.date > $1.date }
            } catch {
                errorMessage = String(localized: "Your saved Watch pages couldn't be opened. Please try again before saving.")
            }
        }
        loadToday()
    }

    var today: WatchJournalEntry? {
        entries.first { Calendar.current.isDateInToday($0.date) }
    }

    var hasChanges: Bool {
        guard let today else { return true }
        return selectedMood != today.mood || note != today.note
    }

    func loadToday() {
        selectedMood = today?.mood ?? .laughing
        note = today?.note ?? ""
    }

    func save() {
        // Never overwrite unreadable storage with an empty journal.
        guard errorMessage == nil else { return }
        var updated = entries
        if let index = updated.firstIndex(where: { Calendar.current.isDateInToday($0.date) }) {
            updated[index].mood = selectedMood
            updated[index].note = note
        } else {
            updated.insert(WatchJournalEntry(id: UUID(), date: Date(), mood: selectedMood, note: note), at: 0)
        }
        do {
            let data = try JSONEncoder().encode(updated)
            defaults.set(data, forKey: storageKey)
            entries = updated
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
