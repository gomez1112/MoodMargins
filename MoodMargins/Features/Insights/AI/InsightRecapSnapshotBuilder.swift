//
//  InsightRecapSnapshotBuilder.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import Foundation

enum InsightRecapSnapshotBuilder {
    static func snapshot(
        from entries: [MoodEntry],
        selectedRange: Int,
        calendar: Calendar = .current,
        now: Date = Date()
    ) -> InsightRecapSnapshot {
        let startOfToday = calendar.startOfDay(for: now)
        let startDate = calendar.date(byAdding: .day, value: -(selectedRange - 1), to: startOfToday) ?? startOfToday
        let filteredEntries = entries
            .filter { $0.date >= startDate && $0.date <= now }
            .sorted { $0.date < $1.date }

        return InsightRecapSnapshot(
            selectedRange: selectedRange,
            entries: filteredEntries.map(entrySnapshot),
            averageMood: MoodInsights.averageMood(filteredEntries),
            trend: trend(for: filteredEntries, selectedRange: selectedRange),
            topTags: topTags(for: filteredEntries, limit: 4),
            topActivities: MoodInsights.topActivities(filteredEntries, limit: 4).map { $0.activity.title.lowercased() }
        )
    }

    private static func entrySnapshot(_ entry: MoodEntry) -> InsightRecapEntrySnapshot {
        InsightRecapEntrySnapshot(
            date: entry.date,
            moodTitle: entry.mood.title,
            moodValue: entry.mood.rawValue,
            noteExcerpt: excerpt(entry.note, limit: 140),
            tags: entry.tags.prefix(6).map { $0.lowercased() },
            activities: (entry.activities ?? []).prefix(4).map { $0.title.lowercased() }
        )
    }

    private static func topTags(for entries: [MoodEntry], limit: Int) -> [String] {
        var counts: [String: Int] = [:]
        for entry in entries {
            for tag in entry.tags {
                counts[tag.lowercased(), default: 0] += 1
            }
        }

        return counts
            .sorted {
                if $0.value == $1.value {
                    return $0.key < $1.key
                }
                return $0.value > $1.value
            }
            .prefix(limit)
            .map(\.key)
    }

    private static func trend(for entries: [MoodEntry], selectedRange: Int) -> InsightRecapTrend {
        let series = MoodInsights.dailyAverages(entries, days: selectedRange)
        guard let first = series.first?.value, let last = series.last?.value, series.count >= 2 else {
            return .unknown
        }

        let delta = last - first
        if delta >= 0.4 { return .improving }
        if delta <= -0.4 { return .declining }
        return .steady
    }

    private static func excerpt(_ note: String, limit: Int) -> String {
        let trimmed = note
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")

        guard trimmed.count > limit else { return trimmed }
        let endIndex = trimmed.index(trimmed.startIndex, offsetBy: limit)
        return String(trimmed[..<endIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
