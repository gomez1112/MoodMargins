//
//  MoodEntry.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/21/26.
//

import Foundation
import SwiftData

typealias MoodEntry = MoodMarginsAppSchemaV1.MoodEntry

enum MoodMarginsAppSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)
    static let models: [any PersistentModel.Type] = [
        MoodEntry.self, Activity.self
    ]
    
    @Model
    final class MoodEntry: Identifiable {
        var id = UUID()
        var date = Date()
        var mood: Mood = Mood.angry
        var note = ""
        var tags: [String] = []
        @Relationship(deleteRule: .cascade, inverse: \Activity.moodEntry)
        var activities: [Activity]? = []
        var sleepQuality: Int = 0 // 0...5
        var energyLevel: Int = 0 //0...5
        
        var sleepFraction: Double {
            Double(sleepQuality) / 5
        }
        var energyFraction: Double {
            Double(energyLevel) / 5
        }
        
        init(date: Date = Date(), mood: Mood, note: String = "", tags: [String], activities: [Activity]? = nil, sleepQuality: Int, energyLevel: Int) {
            self.date = date
            self.mood = mood
            self.note = note
            self.tags = tags
            self.activities = activities
            self.sleepQuality = sleepQuality
            self.energyLevel = energyLevel
        }
    }
}

