//
//  InsightRecapSnapshot.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import Foundation

struct InsightRecapSnapshot: Sendable, Equatable {
    let selectedRange: Int
    let entries: [InsightRecapEntrySnapshot]
    let averageMood: Double
    let trend: InsightRecapTrend
    let topTags: [String]
    let topActivities: [String]
    var modelChoice: FoundationModelChoice = .onDevice

    var entryCount: Int { entries.count }
    var canGenerate: Bool { entries.count >= 2 }

    var identity: String {
        let entryKey = entries.map { entry in
            [String(entry.date.timeIntervalSince1970), String(entry.moodValue), entry.moodTitle,
             entry.noteExcerpt, entry.tags.joined(separator: ","), entry.activities.joined(separator: ",")]
                .map { "\($0.utf8.count):\($0)" }.joined()
        }.joined(separator: "|")
        return "\(selectedRange):\(modelChoice.rawValue):\(entryKey)"
    }

    var promptText: String {
        let entryLines = entries.map { entry in
            let tags = entry.tags.isEmpty ? "none" : entry.tags.joined(separator: ", ")
            let activities = entry.activities.isEmpty ? "none" : entry.activities.joined(separator: ", ")
            let note = entry.noteExcerpt.isEmpty ? "no note excerpt" : entry.noteExcerpt
            return "- \(entry.date.formatted(date: .abbreviated, time: .omitted)): mood \(entry.moodTitle) (\(entry.moodValue)/5), tags: \(tags), activities: \(activities), note: \(note)"
        }.joined(separator: "\n")

        let tags = topTags.isEmpty ? "none" : topTags.joined(separator: ", ")
        let activities = topActivities.isEmpty ? "none" : topActivities.joined(separator: ", ")

        return """
        Create a gentle MoodMargins recap from only this saved diary context.
        Avoid diagnosis, therapy claims, medical advice, prescriptions, certainty, and invented facts.
        Keep each field concise and grounded in the data.

        Range: \(selectedRange) days
        Entries: \(entryCount)
        Average mood: \(averageMood.formatted(.number.precision(.fractionLength(1)))) out of 5
        Trend: \(trend.title)
        Top tags: \(tags)
        Top activities: \(activities)

        Entries:
        \(entryLines)
        """
    }
}

struct InsightRecapEntrySnapshot: Sendable, Equatable {
    let date: Date
    let moodTitle: String
    let moodValue: Int
    let noteExcerpt: String
    let tags: [String]
    let activities: [String]
}

enum InsightRecapTrend: String, Sendable, Equatable {
    case improving
    case declining
    case steady
    case unknown

    var title: String {
        switch self {
        case .improving:
            return "gently improving"
        case .declining:
            return "softening downward"
        case .steady:
            return "mostly steady"
        case .unknown:
            return "not enough trend data"
        }
    }
}
