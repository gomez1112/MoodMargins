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
    private var loadedEntryID: UUID?
    private var draftDate = Date()
    private var savedMood: Mood = .laughing
    private var savedNote = ""
    private var confirmedMood = false
    private var hasUnreadableStorage = false
    private var isCaptureSession = false

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
#if DEBUG
        isCaptureSession = ProcessInfo.processInfo.arguments.contains("--marketing-capture")
        if isCaptureSession {
            entries = [WatchJournalEntry(id: UUID(), date: Date(), mood: .wink, note: String(localized: "A quiet walk."))]
            loadToday()
            return
        }
#endif
        if let data = defaults.data(forKey: storageKey) {
            do {
                entries = try JSONDecoder().decode([WatchJournalEntry].self, from: data).sorted { $0.date > $1.date }
            } catch {
                hasUnreadableStorage = true
                errorMessage = String(localized: "Your saved Watch pages couldn't be opened. Please try again before saving.")
            }
        }
        loadToday()
    }

    var today: WatchJournalEntry? { entries.first { Calendar.current.isDateInToday($0.date) } }
    var hasSelectedMood: Bool { loadedEntryID != nil || confirmedMood }
    var draft: WatchJournalDraft { WatchJournalDraft(date: draftDate, mood: selectedMood, note: note, confirmedMood: confirmedMood) }
    var hasChanges: Bool {
        if loadedEntryID == nil {
            return confirmedMood || !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return selectedMood != savedMood || note != savedNote
    }
    func selectMood(_ mood: Mood) { selectedMood = mood; confirmedMood = true }

    func loadToday() {
        let entry = today
        loadedEntryID = entry?.id
        draftDate = entry?.date ?? Date()
        selectedMood = entry?.mood ?? .laughing
        note = entry?.note ?? ""
        savedMood = selectedMood
        savedNote = note
        confirmedMood = false
    }

    func autosave() async {
        guard hasChanges, !hasUnreadableStorage else { return }
        do {
            try await Task.sleep(for: .milliseconds(500))
            try Task.checkCancellation()
            saveIfChanged()
        } catch is CancellationError { return }
        catch { errorMessage = error.localizedDescription }
    }

    func saveIfChanged() {
        guard hasChanges, !hasUnreadableStorage else { return }
        var updated = entries
        if let index = updated.firstIndex(where: { $0.id == loadedEntryID }) {
            updated[index].mood = selectedMood
            updated[index].note = note
        } else {
            updated.insert(WatchJournalEntry(id: UUID(), date: draftDate, mood: selectedMood, note: note), at: 0)
        }
        do {
            let data = try JSONEncoder().encode(updated)
            if !isCaptureSession { defaults.set(data, forKey: storageKey) }
            entries = updated
            loadedEntryID = updated.first { Calendar.current.isDate($0.date, inSameDayAs: draftDate) }?.id
            savedMood = selectedMood
            savedNote = note
            confirmedMood = false
            errorMessage = nil
        } catch { errorMessage = error.localizedDescription }
    }
}
