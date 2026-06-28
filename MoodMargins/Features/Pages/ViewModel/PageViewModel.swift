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
    var note = String(localized: "Dear diary,")
    var tags: Set<String> = []
    var selectedEntryID: UUID?
    var searchText = ""
    var moodFilter: Mood?

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
            let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let matchesSearch = trimmedSearch.isEmpty
                || entry.note.lowercased().contains(trimmedSearch)
                || entry.tags.contains { $0.lowercased().contains(trimmedSearch) }
                || entry.mood.title.lowercased().contains(trimmedSearch)
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
    }

    func saveCurrentPage(entries: [MoodEntry], modelContext: ModelContext) {
        do {
            try persistCurrentPage(entries: entries, modelContext: modelContext)
        } catch {
            assertionFailure("Failed to save diary page: \(error)")
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
    }
}
