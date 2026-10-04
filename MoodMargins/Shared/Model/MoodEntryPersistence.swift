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
        preferredEntryID: UUID? = nil,
        fallbackMatch: (MoodEntry) -> Bool,
        date: Date,
        mood: Mood,
        note: String,
        tags: [String],
        activities: [Activity] = [],
        sleepQuality: Int = 3,
        energyLevel: Int = 3
    ) throws -> MoodEntry {
        var existing: MoodEntry?
        if let preferredEntryID {
            existing = entries.first { $0.id == preferredEntryID }
            if existing == nil {
                var descriptor = FetchDescriptor<MoodEntry>(predicate: #Predicate { $0.id == preferredEntryID })
                descriptor.fetchLimit = 1
                existing = try modelContext.fetch(descriptor).first
            }
        }
        existing = existing ?? entries.first(where: fallbackMatch)
        if existing == nil {
            let start = Calendar.current.startOfDay(for: date)
            guard let end = Calendar.current.date(byAdding: .day, value: 1, to: start) else {
                throw CocoaError(.coderInvalidValue)
            }
            var descriptor = FetchDescriptor<MoodEntry>(predicate: #Predicate { $0.date >= start && $0.date < end }, sortBy: [SortDescriptor(\.date, order: .reverse)])
            descriptor.fetchLimit = 1
            existing = try modelContext.fetch(descriptor).first
        }
        // A query can still contain its previous render's values during a fast tab change.
        // Check the context before inserting, so autosave doesn't create a duplicate day.
        let entry = existing ?? MoodEntry(
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
