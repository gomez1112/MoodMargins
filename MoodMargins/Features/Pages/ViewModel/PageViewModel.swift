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

    var isShowingSaveError: Bool {
        get { saveErrorMessage != nil }
        set { if !newValue { saveErrorMessage = nil } }
    }

    var hasUnsavedChanges: Bool {
        if let savedSnapshot {
            return selectedMood != savedSnapshot.mood || note != savedSnapshot.note
                || tags != Set(savedSnapshot.tags) || selectedDate != savedSnapshot.date
        }
        return !note.isEmpty || !tags.isEmpty || selectedMood != savedEmptyMood
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
        let preferredMatch: ((MoodEntry) -> Bool)? = selectedEntryID.map { selectedEntryID in
            { entry in entry.id == selectedEntryID }
        }

        let entry = try MoodEntryPersistence.saveEntry(
            in: entries,
            modelContext: modelContext,
            preferredMatch: preferredMatch,
            fallbackMatch: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) },
            date: selectedDate,
            mood: selectedMood,
            note: note,
            tags: selectedTagList
        )

        selectedEntryID = entry.id
        savedSnapshot = DiaryEntrySnapshot(entry)
    }
}
