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
    var tagSuggestionError: String?

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

    var saveErrorMessage: String?

    var isShowingSaveError: Bool {
        get { saveErrorMessage != nil }
        set { if !newValue { saveErrorMessage = nil } }
    }

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
    private var activeTagRequest: UUID?
    private var tagRetryRevision = 0
    private var lastTagSuggestionNote = ""

    /// Status copy that reflects the current editing state of the diary page.
    var statusText: String {
        if pageSaved && !hasPendingChanges { return String(localized: "Today's page saved") }
        if note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return String(localized: "Dear diary…") }
        return String(localized: "Unsaved changes")
    }

    /// A Boolean value indicating whether the editor differs from the last saved snapshot.
    var hasPendingChanges: Bool {
        !pageSaved || hasUnsavedEdits
    }

    private var hasUnsavedEdits: Bool {
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

    /// Refreshes a clean editor from today's saved entry while preserving an independent unsaved draft.
    /// Older entries never become today's draft, and deleting today's entry clears a clean editor.
    ///
    /// - Parameter entries: The available mood entries, usually supplied by a SwiftData query.
    func loadTodayIfNeeded(from entries: [MoodEntry]) {
        guard !didLoadToday || !hasUnsavedEdits else { return }
        didLoadToday = true

        guard let entry = entries.first(where: { Calendar.current.isDateInToday($0.date) }) else {
            selectedMood = .laughing
            note = ""
            selectedTags = []
            savedMood = selectedMood
            savedNote = ""
            savedTags = []
            pageSaved = false
            return
        }
        selectedMood = entry.mood
        note = entry.note
        selectedTags = Set(entry.tags)
        savedMood = entry.mood
        savedNote = entry.note
        savedTags = Set(entry.tags)
        pageSaved = true
        generatedTagSuggestions = []
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
            saveErrorMessage = nil
            try persistTodayPage(entries: entries, modelContext: modelContext)
        } catch {
            saveErrorMessage = error.localizedDescription
        }
    }

    func tagRefreshID(using choice: FoundationModelChoice) -> String {
        "\(choice.rawValue):\(tagRetryRevision):\(note)"
    }

    func retryTagSuggestions() {
        lastTagSuggestionNote = ""
        tagRetryRevision += 1
    }

    /// SwiftUI owns this debounced task and cancels it when the note, model, or view lifetime changes.
    func generateTagSuggestions(using modelChoice: FoundationModelChoice, hasPlus: Bool) async {
        let requestID = UUID()
        activeTagRequest = requestID
        tagSuggestionError = nil
        isGeneratingTagSuggestions = false
        guard hasPlus else {
            generatedTagSuggestions = []
            lastTagSuggestionNote = ""
            return
        }
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedNote.count >= 12 else {
            generatedTagSuggestions = []
            lastTagSuggestionNote = ""
            return
        }
        let identity = modelChoice.rawValue + ":" + trimmedNote
        guard identity != lastTagSuggestionNote else { return }
        generatedTagSuggestions = []
        defer {
            if activeTagRequest == requestID { isGeneratingTagSuggestions = false }
        }
        do {
            try await Task.sleep(for: .milliseconds(800))
            try Task.checkCancellation()
            isGeneratingTagSuggestions = true
            let request = MoodTaggingRequest(note: trimmedNote, selectedTags: selectedTags, modelChoice: modelChoice)
            try await tagProvider.generateSuggestions(for: request) { suggestions in
                guard !Task.isCancelled, self.activeTagRequest == requestID else { return }
                self.generatedTagSuggestions = MoodTagNormalizer.normalizedTags(suggestions, excluding: self.selectedTags)
            }
            try Task.checkCancellation()
            if activeTagRequest == requestID { lastTagSuggestionNote = identity }
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled, activeTagRequest == requestID else { return }
            tagSuggestionError = FoundationModelsErrorPresenter.message(for: error)
            generatedTagSuggestions = []
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
