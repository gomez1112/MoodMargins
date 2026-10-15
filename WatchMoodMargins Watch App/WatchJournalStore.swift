import Foundation
import Observation
import SwiftData

/// Editable value drafts backed by the shared private-iCloud journal.
@MainActor
@Observable
final class WatchJournalStore {
    private(set) var entries: [WatchJournalEntry] = []
    var selectedMood: Mood = .laughing
    var note = ""
    var errorMessage: String?
    private let persistence: WatchJournalPersistence
    private var loadedEntryID: UUID?
    private var draftDate = Date()
    private var savedMood: Mood = .laughing
    private var savedNote = ""
    private var confirmedMood = false
    private var hasUnreadableStorage = false
    private var isCaptureSession = false

    init(container: ModelContainer, defaults: UserDefaults = .standard) {
        persistence = WatchJournalPersistence(container: container, defaults: defaults)
#if DEBUG
        isCaptureSession = ProcessInfo.processInfo.arguments.contains("--marketing-capture")
        if isCaptureSession {
            let examples: [(Mood, String)] = [
                (.wink, String(localized: "A quiet walk.")),
                (.laughing, String(localized: "Time with friends.")),
                (.mourn, String(localized: "A moment to rest.")),
                (.sad, String(localized: "One day at a time."))
            ]
            entries = examples.enumerated().compactMap { index, example in
                guard let date = Calendar.current.date(byAdding: .day, value: -index, to: Date()) else { return nil }
                return WatchJournalEntry(id: UUID(), date: date, mood: example.0, note: example.1)
            }
            loadToday()
            return
        }
#endif
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
        guard !hasChanges else { return }
        if !isCaptureSession {
            do {
                entries = try persistence.load()
                hasUnreadableStorage = false
                errorMessage = nil
            } catch {
                hasUnreadableStorage = true
                errorMessage = String(localized: "Your saved Watch pages couldn't be opened. Please try again before saving.")
                return
            }
        }
        restoreCleanDraft()
    }

    /// Query updates include iCloud imports and deletions. Keep a person's unfinished draft intact.
    func synchronize(from entries: [WatchJournalEntry]) {
        guard !isCaptureSession, !hasUnreadableStorage else { return }
        let wasEditing = hasChanges
        self.entries = entries
        if !wasEditing { restoreCleanDraft() }
    }

    private func restoreCleanDraft() {
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
        do {
            guard !isCaptureSession else { return }
            let entry = try persistence.save(
                id: loadedEntryID, date: draftDate,
                mood: confirmedMood || selectedMood != savedMood ? selectedMood : nil,
                note: note != savedNote ? note : nil
            )
            entries = try persistence.load()
            loadedEntryID = entry.id
            selectedMood = entry.mood
            note = entry.note
            savedMood = selectedMood
            savedNote = note
            confirmedMood = false
            errorMessage = nil
        } catch { errorMessage = error.localizedDescription }
    }
}
