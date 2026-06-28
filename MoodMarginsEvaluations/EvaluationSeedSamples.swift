//
//  EvaluationSeedSamples.swift
//  MoodMarginsEvaluations
//
//  Created by Gerard Gomez on 6/28/26.
//

import Foundation

#if canImport(Evaluations) && canImport(FoundationModels)
import Evaluations
import FoundationModels

@available(iOS 27.0, macOS 27.0, visionOS 27.0, watchOS 27.0, *)
@Generable
struct TagSuggestionExpected: Codable, Sendable, Equatable {
    @Guide(description: "Relevant lowercase diary tags.", .maximumCount(4))
    var tags: [String]
}

@available(iOS 27.0, macOS 27.0, visionOS 27.0, watchOS 27.0, *)
@Generable
struct InsightRecapExpected: Codable, Sendable, Equatable {
    var title: String
    var pattern: String
    var supportingDetail: String
    var gentleReflection: String
    var nextPrompt: String
}

@available(iOS 27.0, macOS 27.0, visionOS 27.0, watchOS 27.0, *)
enum EvaluationSeedSamples {
    static let tagSuggestionSeeds: [ModelSample<TagSuggestionExpected>] = [
        ModelSample(
            prompt: "I took a quiet walk before work and felt calmer than yesterday.",
            expected: TagSuggestionExpected(tags: ["walk", "work", "calm"])
        ),
        ModelSample(
            prompt: "Dinner with my sister was loud but sweet, and I laughed more than I expected.",
            expected: TagSuggestionExpected(tags: ["family", "dinner", "laughing"])
        ),
        ModelSample(
            prompt: "I stayed up too late finishing a deadline and woke up tired.",
            expected: TagSuggestionExpected(tags: ["work", "tired", "deadline"])
        ),
        ModelSample(
            prompt: "A slow morning with coffee and reading helped me feel rested.",
            expected: TagSuggestionExpected(tags: ["morning", "reading", "rest"])
        )
    ]

    static let insightRecapSeeds: [ModelSample<InsightRecapExpected>] = [
        ModelSample(
            prompt: "Range: 7 days. Entries: 4. Average mood: 3.8. Trend: gently improving. Top tags: calm, rest. Notes mention walks, reading, and better sleep.",
            expected: InsightRecapExpected(
                title: "A steadier stretch",
                pattern: "Calm and rest showed up alongside a gently improving mood trend.",
                supportingDetail: "The range averaged 3.8 out of 5 with calm and rest as top tags.",
                gentleReflection: "The quieter routines seem worth noticing without turning them into rules.",
                nextPrompt: "What helped today feel a little steadier?"
            )
        ),
        ModelSample(
            prompt: "Range: 14 days. Entries: 3. Average mood: 2.3. Trend: softening downward. Top tags: work, tired. Notes mention deadlines and skipped rest.",
            expected: InsightRecapExpected(
                title: "A heavier patch",
                pattern: "Work and tired tags appeared during a lower mood stretch.",
                supportingDetail: "The average mood was 2.3 out of 5, with deadlines appearing in note excerpts.",
                gentleReflection: "This looks like a demanding period, and it can be enough to simply name it.",
                nextPrompt: "Where did you find even a small pocket of ease?"
            )
        )
    ]
}
#else
enum EvaluationSeedSamples {}
#endif
