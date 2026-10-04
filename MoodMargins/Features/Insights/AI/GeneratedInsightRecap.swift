//
//  GeneratedInsightRecap.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import Foundation

import FoundationModels

@Generable
struct GeneratedInsightRecap: Sendable, Equatable {
    @Guide(description: "A short warm title for this mood recap.")
    let title: String

    @Guide(description: "One observed pattern grounded only in the provided entries.")
    let pattern: String

    @Guide(description: "A concrete detail from the mood, tag, activity, or note summary that supports the pattern.")
    let supportingDetail: String

    @Guide(description: "A gentle reflective sentence. Do not diagnose, prescribe, or make medical claims.")
    let gentleReflection: String

    @Guide(description: "One short journaling prompt for the next entry.")
    let nextPrompt: String
}


struct PartialGeneratedInsightRecap: Sendable, Equatable {
    var title: String?
    var pattern: String?
    var supportingDetail: String?
    var gentleReflection: String?
    var nextPrompt: String?

    static let empty = PartialGeneratedInsightRecap()

    static func fallback(for selectedRange: Int) -> PartialGeneratedInsightRecap {
        PartialGeneratedInsightRecap(
            title: selectedRange == 365 ? String(localized: "Year recap") : String(localized: "\(selectedRange)-day recap"),
            pattern: String(localized: "Add a few more pages to unlock a softer generated recap."),
            supportingDetail: String(localized: "MoodMargins needs at least two saved entries in this range to find a pattern."),
            gentleReflection: String(localized: "Your notes can stay simple; small details are enough."),
            nextPrompt: String(localized: "What is one small thing worth remembering from today?")
        )
    }
}

extension PartialGeneratedInsightRecap {
    init(_ content: GeneratedInsightRecap.PartiallyGenerated) {
        self.init(
            title: content.title,
            pattern: content.pattern,
            supportingDetail: content.supportingDetail,
            gentleReflection: content.gentleReflection,
            nextPrompt: content.nextPrompt
        )
    }
}
