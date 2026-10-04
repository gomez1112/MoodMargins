//
//  MoodInsights.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/27/26.
//

import Foundation

/// Calculates aggregate mood and activity statistics for insight views.
enum MoodInsights {
    static func dateRange(days: Int, calendar: Calendar = .current, now: Date = Date()) -> ClosedRange<Date> {
        let today = calendar.startOfDay(for: now)
        let start = calendar.date(byAdding: .day, value: -(max(days, 1) - 1), to: today) ?? today
        let end = calendar.date(byAdding: .day, value: 1, to: today) ?? now
        return start...end
    }

    static func chartDateRange(days: Int, calendar: Calendar = .current, now: Date = Date()) -> ClosedRange<Date> {
        let range = dateRange(days: days, calendar: calendar, now: now)
        let today = calendar.startOfDay(for: now)
        return range.lowerBound...(today > range.lowerBound ? today : range.upperBound)
    }

    static func chartTickDates(days: Int, calendar: Calendar = .current, now: Date = Date()) -> [Date] {
        let range = chartDateRange(days: days, calendar: calendar, now: now)
        let middle = calendar.date(byAdding: .day, value: max(days - 1, 0) / 2, to: range.lowerBound) ?? range.lowerBound
        return Set([range.lowerBound, middle, range.upperBound]).sorted()
    }

    static func overallMoodSummary(_ entries: [MoodEntry]) -> String {
        guard !entries.isEmpty else { return "—" }
        if entries.count == 1 { return entries[0].mood.title }
        let days = Dictionary(grouping: entries) { Calendar.current.startOfDay(for: $0.date) }
        let dailyMoods = days.values.map(averageMood)
        // A balanced day stays mixed instead of being rounded into a lighter or heavier mood.
        let lighterCount = dailyMoods.filter { $0 >= Double(Mood.wink.rawValue) }.count
        let heavierCount = dailyMoods.filter { $0 <= Double(Mood.mourn.rawValue) }.count
        if lighterCount * 2 > dailyMoods.count { return String(localized: "Mostly lighter days") }
        if heavierCount * 2 > dailyMoods.count { return String(localized: "Mostly heavier days") }
        return String(localized: "A mix of moods")
    }

    static func moodDescription(for value: Double) -> String {
        let lower = Mood(rawValue: min(max(Int(value.rounded(.down)), 1), 5)) ?? .mourn
        let upper = Mood(rawValue: min(max(Int(value.rounded(.up)), 1), 5)) ?? .mourn
        return lower == upper ? lower.title : String(localized: "Between \(lower.title) and \(upper.title)")
    }

    static func entries(_ entries: [MoodEntry], days: Int, calendar: Calendar = .current, now: Date = Date()) -> [MoodEntry] {
        let range = dateRange(days: days, calendar: calendar, now: now)
        return entries.filter { $0.date >= range.lowerBound && $0.date <= now }
    }

    /// A missed today does not reset yesterday's streak before the person has checked in.
    static func currentStreak(_ entries: [MoodEntry], calendar: Calendar = .current, now: Date = Date()) -> Int {
        let days = Set(entries.filter { $0.date <= now }.map { calendar.startOfDay(for: $0.date) })
        var day = calendar.startOfDay(for: now)
        if !days.contains(day) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: day) else { return 0 }
            day = yesterday
        }
        var count = 0
        while days.contains(day) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return count
    }

    static func pattern(_ entries: [MoodEntry]) -> String {
        guard !entries.isEmpty else {
            return String(localized: "Save a page to start noticing patterns in your days.")
        }
        var groups: [String: [MoodEntry]] = [:]
        for entry in entries {
            for tag in Set(entry.tags.map { $0.lowercased() }) {
                groups[tag, default: []].append(entry)
            }
        }
        guard let group = groups.sorted(by: {
            $0.value.count == $1.value.count ? $0.key < $1.key : $0.value.count > $1.value.count
        }).first, group.value.count >= 2 else {
            return String(localized: "Use the same tag on a few pages to see how those days compare.")
        }
        let counts = distribution(group.value)
        let highest = counts.map(\.count).max() ?? 0
        let common = counts.filter { $0.count == highest }
        if common.count == 1, let mood = common.first?.mood {
            return String(localized: "\(group.value.count) pages shared #\(group.key). Their most common mood was \(mood.title).")
        }
        return String(localized: "\(group.value.count) pages shared #\(group.key), with a mix of moods.")
    }
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

     Days without entries are omitted, with separate line segments on either side of each gap.
     The calendar date is the stable identifier and the horizontal chart position.

     - Parameters:
       - entries: The mood entries to group by calendar day.
       - days: The number of recent days to inspect, counting back from the current date. The default is `14`.
     - Returns: A list of daily mood averages for days that contain at least one entry.
     */
    static func dailyAverages(_ entries: [MoodEntry], days: Int = 14, calendar: Calendar = .current, now: Date = Date()) -> [DailyMood] {
        guard days > 0 else { return [] }
        let included = self.entries(entries, days: days, calendar: calendar, now: now)
        let grouped = Dictionary(grouping: included) { calendar.startOfDay(for: $0.date) }
        let dates = grouped.keys.sorted()
        var segmentStart = dates.first ?? calendar.startOfDay(for: now)
        var previousDate: Date?
        return dates.map { date in
            if let previousDate, calendar.date(byAdding: .day, value: 1, to: previousDate) != date {
                segmentStart = date
            }
            previousDate = date
            return DailyMood(date: date, value: averageMood(grouped[date] ?? []), segmentStart: segmentStart)
        }
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
        guard limit > 0 else { return [] }
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
