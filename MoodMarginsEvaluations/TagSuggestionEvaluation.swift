//
//  TagSuggestionEvaluation.swift
//  MoodMarginsEvaluations
//
//  Created by Gerard Gomez on 6/28/26.
//

import Foundation

#if canImport(Evaluations) && canImport(FoundationModels)
import Evaluations
import FoundationModels

@available(iOS 27.0, macOS 27.0, visionOS 27.0, watchOS 27.0, *)
struct TagSuggestionEvaluationNotes {
    static let criteria = [
        "Tags are relevant to the diary entry.",
        "Tags are lowercase, concise, and non-diagnostic.",
        "Generated tags avoid advice and full sentences."
    ]
}
#endif
