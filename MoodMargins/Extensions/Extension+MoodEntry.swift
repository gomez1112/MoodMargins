//
//  Extension+MoodEntry.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/21/26.
//

import Foundation
extension MoodEntry {
    /// Roughly two weeks of believable entries for previews, timelines, and charts.
    @MainActor static var samples: [MoodEntry] {
        let calendar = Calendar.current
        let now = Date()
        let library = Activity.library
        
        // (daysAgo, hour, mood, note, tags, activityIndexes, sleep, energy)
        let blueprint: [(Int, Int, Mood, String, [String], [Int], Int, Int)] = [
            (0,  9,  .wink,  "Slept in and made a real breakfast.",        ["calm", "morning"],   [3, 8], 4, 3),
            (0,  20, .angry, "Long walk at sunset cleared my head.",       ["grateful"],          [6, 1], 4, 4),
            (1,  13, .mourn,  "Busy afternoon, a bit scattered.",           ["work"],              [0],    3, 2),
            (2,  8,  .sad,   "Rough start, didn't sleep well.",            ["tired"],             [0, 7], 1, 1),
            (2,  19, .mourn,  "Dinner with friends helped.",                ["social"],            [2, 8], 1, 3),
            (3,  18, .wink,  "Finished a big task, felt productive.",      ["work", "proud"],     [0, 4], 3, 4),
            (4,  11, .laughing, "Sunny and energetic all morning.",           ["happy"],             [1, 6], 5, 5),
            (5,  21, .mourn,  "Quiet evening, a little restless.",          ["calm"],              [4, 5], 3, 2),
            (6,  10, .sad,   "Anxious about deadlines.",                   ["anxious", "work"],   [0],    2, 2),
            (7,  16, .wink,  "Music and a clean apartment.",               ["calm"],              [5, 7], 4, 3),
            (8,  9,  .mourn,  "Average Monday.",                            ["work"],              [0],    3, 3),
            (9,  20, .laughing, "Trip planning got me excited.",              ["excited"],           [9, 2], 4, 4),
            (10, 12, .wink,  "Good lunch, good company.",                  ["social"],            [2, 8], 3, 3),
            (11, 7,  .sad,   "Woke up tired and foggy.",                   ["tired"],             [7],    1, 1),
            (12, 19, .angry,  "Read for a while, settled down.",            ["calm"],              [4],    3, 2),
            (13, 17, .angry,  "Workout left me feeling strong.",            ["healthy"],           [1, 6], 4, 4)
        ]
        
        return blueprint.compactMap { daysAgo, hour, mood, note, tags, activityIdx, sleep, energy in
            var components = calendar.dateComponents([.year, .month, .day], from: now)
            components.hour = hour
            guard let base = calendar.date(from: components),
                  let date = calendar.date(byAdding: .day, value: -daysAgo, to: base) else { return nil }
            return MoodEntry(
                date: date,
                mood: mood,
                note: note,
                tags: tags,
                activities: activityIdx.map { library[$0] },
                sleepQuality: sleep,
                energyLevel: energy
            )
        }
    }
    
    /// The most recent entry, handy for "today" headers.
    @MainActor static var latest: MoodEntry {
        samples.max(by: { $0.date < $1.date })!
    }
}
