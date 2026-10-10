//
//  PageViewModel.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class PageViewModel {
    var selectedDate = Date()
    var selectedMood: Mood = .laughing
    var note = ""
    var tags: Set<String> = []
    var selectedEntryID: UUID?
    var searchText = ""
    var moodFilter: Mood?

    var saveErrorMessage: String?
    private var savedSnapshot: DiaryEntrySnapshot?
    private var didLoad = false
    private var savedEmptyMood: Mood = .laughing
    private var confirmedMood = false

    var autosaveDraft: DiaryDraft {
        DiaryDraft(date: selectedDate, mood: selectedMood, note: note, tags: tags, confirmedMood: confirmedMood)
    }

    var saveStatus: String {
        if saveErrorMessage != nil { return String(localized: "Couldn't save changes") }
        if hasUnsavedChanges { return String(localized: "Saving…") }
        return savedSnapshot == nil ? String(localized: "Changes save automatically") : String(localized: "Saved automatically")
    }

    func selectMood(_ mood: Mood) { selectedMood = mood; confirmedMood = true }

    func autosave(entries: [MoodEntry], modelContext: ModelContext) async {
        guard didLoad, hasUnsavedChanges else { return }
        do {
            try await Task.sleep(for: .milliseconds(500))
            try Task.checkCancellation()
            saveIfChanged(entries: entries, modelContext: modelContext)
        } catch is CancellationError { return }
        catch { saveErrorMessage = error.localizedDescription }
    }

    @discardableResult
    func saveIfChanged(entries: [MoodEntry], modelContext: ModelContext) -> Bool {
        guard didLoad, hasUnsavedChanges else { return true }
        saveCurrentPage(entries: entries, modelContext: modelContext)
        return saveErrorMessage == nil
    }

    func selectEntry(_ entry: MoodEntry, entries: [MoodEntry], modelContext: ModelContext) {
        guard saveIfChanged(entries: entries, modelContext: modelContext) else { return }
        loadEntry(entry)
    }

    func didDeleteEntry(_ id: UUID) {
        guard selectedEntryID == id else { return }
        selectedEntryID = nil
        savedSnapshot = nil
        note = ""
        tags = []
        selectedMood = .laughing
        savedEmptyMood = selectedMood
        confirmedMood = false
    }

    var isShowingSaveError: Bool {
        get { saveErrorMessage != nil }
        set { if !newValue { saveErrorMessage = nil } }
    }

    var hasUnsavedChanges: Bool {
        if let savedSnapshot {
            return selectedMood != savedSnapshot.mood || note != savedSnapshot.note
                || tags != Set(savedSnapshot.tags) || selectedDate != savedSnapshot.date
        }
        return !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !tags.isEmpty || selectedMood != savedEmptyMood || confirmedMood
    }

    /// Updates only a clean draft, including when Today edits or deletes the selected page.
    func synchronize(from entries: [MoodEntry]) {
        guard !didLoad || !hasUnsavedChanges else { return }
        didLoad = true
        let entry = selectedEntryID.flatMap { id in entries.first { $0.id == id } }
            ?? entries.first { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
        if let entry {
            loadEntry(entry)
        } else {
            selectedEntryID = nil
            selectedMood = .laughing
            savedEmptyMood = selectedMood
            note = ""
            tags = []
            savedSnapshot = nil
            confirmedMood = false
        }
    }

    let tagGroups = [
        PageTagGroup(title: String(localized: "Feelings"), tags: [String(localized: "calm"), String(localized: "anxious"), String(localized: "hopeful"), String(localized: "grateful")]),
        PageTagGroup(title: String(localized: "Activities"), tags: [String(localized: "walk"), String(localized: "work"), String(localized: "reading"), String(localized: "music")]),
        PageTagGroup(title: String(localized: "Context"), tags: [String(localized: "social"), String(localized: "alone"), String(localized: "family"), String(localized: "outdoors")]),
        PageTagGroup(title: String(localized: "Body"), tags: [String(localized: "tired"), String(localized: "energized"), String(localized: "rested"), String(localized: "cozy")])
    ]

    var selectedTagList: [String] {
        MoodEntryTagOrderer.orderedTags(
            selectedTags: tags,
            knownTags: tagGroups.flatMap(\.tags),
            includesCustomTags: true
        )
    }

    func filteredEntries(from entries: [MoodEntry]) -> [MoodEntry] {
        entries.filter { entry in
            let matchesMood = moodFilter == nil || entry.mood == moodFilter
            let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let matchesSearch = trimmedSearch.isEmpty
                || entry.note.localizedStandardContains(trimmedSearch)
                || entry.tags.contains { $0.localizedStandardContains(trimmedSearch) }
                || entry.mood.title.localizedStandardContains(trimmedSearch)
            return matchesMood && matchesSearch
        }
    }

    func calendarEntries(from entries: [MoodEntry]) -> [MoodEntry] {
        let calendar = Calendar.current
        let entriesByDay = Dictionary(grouping: entries) { entry in
            calendar.startOfDay(for: entry.date)
        }

        return entriesByDay.values
            .compactMap { dayEntries in
                dayEntries.max { $0.date < $1.date }
            }
            .sorted { $0.date > $1.date }
    }

    func daysWithMultipleEntries(in entries: [MoodEntry]) -> Set<Date> {
        let calendar = Calendar.current
        let entriesByDay = Dictionary(grouping: filteredEntries(from: entries)) { entry in
            calendar.startOfDay(for: entry.date)
        }

        return Set(entriesByDay.compactMap { day, dayEntries in
            dayEntries.count > 1 ? day : nil
        })
    }

    func loadEntry(_ entry: MoodEntry) {
        selectedDate = entry.date
        selectedMood = entry.mood
        note = entry.note
        tags = Set(entry.tags)
        selectedEntryID = entry.id
        savedSnapshot = DiaryEntrySnapshot(entry)
        didLoad = true
        confirmedMood = false
    }

    func saveCurrentPage(entries: [MoodEntry], modelContext: ModelContext) {
        do {
            saveErrorMessage = nil
            try persistCurrentPage(entries: entries, modelContext: modelContext)
        } catch {
            saveErrorMessage = error.localizedDescription
        }
    }

    func toggleTag(_ tag: String) {
        if tags.contains(tag) {
            tags.remove(tag)
        } else {
            tags.insert(tag)
        }
    }

    private func persistCurrentPage(entries: [MoodEntry], modelContext: ModelContext) throws {
        let entry = try MoodEntryPersistence.saveEntry(
            in: entries,
            modelContext: modelContext,
            preferredEntryID: selectedEntryID,
            fallbackMatch: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) },
            date: selectedDate,
            mood: selectedMood,
            note: note,
            tags: selectedTagList
        )

        selectedEntryID = entry.id
        savedSnapshot = DiaryEntrySnapshot(entry)
        confirmedMood = false
    }
}
