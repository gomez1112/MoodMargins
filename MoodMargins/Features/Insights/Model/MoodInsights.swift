//
//  MoodInsights.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/27/26.
//

import Foundation

/// Calculates aggregate mood and activity statistics for insight views.
enum MoodInsights {
    /**
     Returns the average mood score across the provided entries.

     Mood scores are based on the raw value of each entry's ``Mood``, expected to fall in the `1...5` range.

     - Parameter entries: The mood entries to include in the calculation.
     - Returns: The arithmetic mean of the mood raw values, or `0` when `entries` is empty.
     */
    static func averageMood(_ entries: [MoodEntry]) -> Double {
        guard !entries.isEmpty else { return 0 }
        return Double(entries.map(\.mood.rawValue).reduce(0, +)) / Double(entries.count)
    }

    /**
     Returns daily average mood values for recent calendar days, ordered from oldest to newest.

     Days without entries are omitted from the result. Each returned ``DailyMood`` receives a sequential identifier based on its position in the filtered result.

     - Parameters:
       - entries: The mood entries to group by calendar day.
       - days: The number of recent days to inspect, counting back from the current date. The default is `14`.
     - Returns: A list of daily mood averages for days that contain at least one entry.
     */
    static func dailyAverages(_ entries: [MoodEntry], days: Int = 14) -> [DailyMood] {
        let calendar = Calendar.current
        let now = Date()
        let raw: [(date: Date, value: Double)] = (0..<days).reversed().compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: now) else { return nil }
            let dayEntries = entries.filter { calendar.isDate($0.date, inSameDayAs: day) }
            guard !dayEntries.isEmpty else { return nil }
            let avg = Double(dayEntries.map(\.mood.rawValue).reduce(0, +)) / Double(dayEntries.count)
            return (day, avg)
        }
        return raw.enumerated().map { DailyMood(id: $0.offset, date: $0.element.date, value: $0.element.value) }
    }

    /**
     Counts how many entries use each available mood.

     The returned values follow ``Mood/allCases`` order, which presents moods from awful through great.

     - Parameter entries: The mood entries to count.
     - Returns: One ``MoodCount`` for each available mood, including moods with a count of `0`.
     */
    static func distribution(_ entries: [MoodEntry]) -> [MoodCount] {
        Mood.allCases.map { mood in
            MoodCount(mood: mood, count: entries.filter { $0.mood == mood }.count)
        }
    }

    /**
     Returns the most frequently selected activities across the provided entries.

     Entries without activities do not contribute to the result.

     - Parameters:
       - entries: The mood entries whose activities should be counted.
       - limit: The maximum number of activity counts to return. The default is `5`.
     - Returns: Activity counts sorted by descending frequency.
     */
    static func topActivities(_ entries: [MoodEntry], limit: Int = 5) -> [ActivityCount] {
        var counts: [String: (activity: Activity, count: Int)] = [:]

        for entry in entries {
            for activity in entry.activities ?? [] {
                let key = activity.title
                if let existingCount = counts[key] {
                    counts[key] = (existingCount.activity, existingCount.count + 1)
                } else {
                    counts[key] = (activity, 1)
                }
            }
        }

        return counts.values
            .sorted {
                if $0.count == $1.count {
                    return $0.activity.title < $1.activity.title
                }
                return $0.count > $1.count
            }
            .prefix(limit)
            .map { ActivityCount(activity: $0.activity, count: $0.count) }
    }
}
