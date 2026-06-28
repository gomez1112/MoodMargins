//
//  TodayViewModel.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/27/26.
//

import Foundation
import Observation
import SwiftData

/// Stores and persists the editable state for the Today diary page.
///
/// `TodayViewModel` tracks the in-progress mood entry, compares it with the last
/// saved snapshot, and exposes derived strings used by the Today screen controls.
@MainActor
@Observable
final class TodayViewModel {
    /// The mood currently selected in the editor.
    var selectedMood: Mood = .laughing

    /// The draft diary note for the current page.
    var note = ""

    /// The tag identifiers currently selected in the editor.
    var selectedTags: Set<String> = []

    /// Suggested tags generated from the draft note.
    var generatedTagSuggestions: [String] = []

    /// A Boolean value indicating whether tag suggestions are currently generating.
    var isGeneratingTagSuggestions = false

    /// The mood value from the last loaded or saved entry.
    var savedMood: Mood = .angry

    /// The note text from the last loaded or saved entry.
    var savedNote = ""

    /// The selected tag identifiers from the last loaded or saved entry.
    var savedTags: Set<String> = []

    /// A Boolean value indicating whether the page has been saved at least once and still matches the saved snapshot.
    var pageSaved = false

    /// A Boolean value indicating whether the view model has already attempted to load an entry for the current session.
    var didLoadToday = false

    /// The fixed set of tags shown as quick suggestions on the Today page.
    let suggestedTags = [
        String(localized: "grateful"),
        String(localized: "tired"),
        String(localized: "social"),
        String(localized: "calm"),
        String(localized: "work"),
        String(localized: "rest"),
        String(localized: "outdoors")
    ]

    private let tagProvider = FoundationMoodTaggingProvider()
    private var tagSuggestionTask: Task<Void, Never>?
    private var lastTagSuggestionNote = ""

    /// Status copy that reflects the current editing state of the diary page.
    var statusText: String {
        if pageSaved && !hasPendingChanges { return String(localized: "Today's page saved") }
        if note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return String(localized: "Dear diary...") }
        return String(localized: "Draft updates live")
    }

    /// A Boolean value indicating whether the editor differs from the last saved snapshot.
    var hasPendingChanges: Bool {
        selectedMood != savedMood || note != savedNote || selectedTags != savedTags
    }

    /// The title shown on the save button for the current editing state.
    var saveButtonTitle: String {
        pageSaved && !hasPendingChanges ? String(localized: "Saved") : String(localized: "Save")
    }

    /// The selected tags in the same order as `suggestedTags`, with generated custom tags appended alphabetically.
    var selectedTagList: [String] {
        MoodEntryTagOrderer.orderedTags(
            selectedTags: selectedTags,
            knownTags: suggestedTags,
            includesCustomTags: true
        )
    }

    /// The number of selected tags hidden when only the first four selected tags are displayed.
    var hiddenSelectedTagCount: Int {
        max(selectedTagList.count - 4, 0)
    }

    /// Loads the editor state from today's entry once per view-model lifecycle.
    ///
    /// If no entry exists for today, the first entry in `entries` is used as a fallback.
    /// Calling this method after the first load attempt has no effect.
    ///
    /// - Parameter entries: The available mood entries, usually supplied by a SwiftData query.
    func loadTodayIfNeeded(from entries: [MoodEntry]) {
        guard !didLoadToday else { return }
        didLoadToday = true

        guard let entry = entries.first(where: { Calendar.current.isDateInToday($0.date) }) ?? entries.first else { return }
        selectedMood = entry.mood
        note = entry.note
        selectedTags = Set(entry.tags)
        savedMood = entry.mood
        savedNote = entry.note
        savedTags = Set(entry.tags)
        pageSaved = true
    }

    /// Saves the current Today page state into SwiftData.
    ///
    /// This method updates today's existing entry when one is available, otherwise it
    /// inserts a new entry with default activity, sleep, and energy values.
    ///
    /// - Parameters:
    ///   - entries: The available mood entries used to find an existing entry for today.
    ///   - modelContext: The SwiftData model context used to insert and save the entry.
    func saveTodayPage(entries: [MoodEntry], modelContext: ModelContext) {
        do {
            try persistTodayPage(entries: entries, modelContext: modelContext)
        } catch {
            assertionFailure("Failed to save today's mood entry: \(error)")
        }
    }

    /// Schedules a debounced Foundation Models content-tagging request for the current note.
    func scheduleTagSuggestions() {
        tagSuggestionTask?.cancel()

        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedNote.count >= 12 else {
            generatedTagSuggestions = []
            isGeneratingTagSuggestions = false
            lastTagSuggestionNote = ""
            return
        }

        guard trimmedNote != lastTagSuggestionNote else { return }

        generatedTagSuggestions = []
        tagSuggestionTask = Task { [tagProvider] in
            try? await Task.sleep(for: .milliseconds(800))
            guard !Task.isCancelled else { return }

            isGeneratingTagSuggestions = true

            do {
                let request = MoodTaggingRequest(note: trimmedNote, selectedTags: selectedTags)
                try await tagProvider.generateSuggestions(for: request) { suggestions in
                    generatedTagSuggestions = suggestions
                }
                guard !Task.isCancelled else { return }

                lastTagSuggestionNote = trimmedNote
            } catch {
                guard !Task.isCancelled else { return }
                generatedTagSuggestions = []
                lastTagSuggestionNote = trimmedNote
            }

            isGeneratingTagSuggestions = false
        }
    }

    /// Selects a generated tag suggestion and removes it from the suggestion list.
    func selectGeneratedTag(_ tag: String) {
        let normalized = MoodTagNormalizer.normalizedTag(tag)
        guard !normalized.isEmpty else { return }

        pageSaved = false
        selectedTags.insert(normalized)
        generatedTagSuggestions.removeAll { MoodTagNormalizer.normalizedTag($0) == normalized }
    }

    func cancelTagSuggestions() {
        tagSuggestionTask?.cancel()
        tagSuggestionTask = nil
        isGeneratingTagSuggestions = false
    }

    /// Persists the current editor values and refreshes the saved snapshot.
    ///
    /// - Parameters:
    ///   - entries: The available mood entries used to find an existing entry for today.
    ///   - modelContext: The SwiftData model context used to insert and save the entry.
    /// - Throws: Any error thrown by `ModelContext.save()`.
    private func persistTodayPage(entries: [MoodEntry], modelContext: ModelContext) throws {
        let saveDate = Date()
        try MoodEntryPersistence.saveEntry(
            in: entries,
            modelContext: modelContext,
            fallbackMatch: { Calendar.current.isDateInToday($0.date) },
            date: saveDate,
            mood: selectedMood,
            note: note,
            tags: selectedTagList
        )

        savedMood = selectedMood
        savedNote = note
        savedTags = selectedTags
        pageSaved = true
    }

    /// Marks the page as unsaved when the draft note no longer matches the saved note.
    func markPageUnsavedIfNoteChanged() {
        if note != savedNote {
            pageSaved = false
        }
    }
}
