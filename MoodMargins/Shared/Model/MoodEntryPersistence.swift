//
//  MoodEntryPersistence.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import Foundation
import SwiftData

enum MoodEntryPersistence {
    @discardableResult
    static func saveEntry(
        in entries: [MoodEntry],
        modelContext: ModelContext,
        preferredMatch: ((MoodEntry) -> Bool)? = nil,
        fallbackMatch: (MoodEntry) -> Bool,
        date: Date,
        mood: Mood,
        note: String,
        tags: [String],
        activities: [Activity] = [],
        sleepQuality: Int = 3,
        energyLevel: Int = 3
    ) throws -> MoodEntry {
        let entry = preferredMatch.flatMap { match in
            entries.first(where: match)
        } ?? entries.first(where: fallbackMatch) ?? MoodEntry(
            date: date,
            mood: mood,
            note: note,
            tags: tags,
            activities: activities,
            sleepQuality: sleepQuality,
            energyLevel: energyLevel
        )

        if entry.modelContext == nil {
            modelContext.insert(entry)
        }

        entry.date = date
        entry.mood = mood
        entry.note = note
        entry.tags = tags

        do {
            try modelContext.save()
            return entry
        } catch {
            // Editors retain value drafts; revert model changes so a failed save does not look persisted.
            modelContext.rollback()
            throw error
        }
    }
}
