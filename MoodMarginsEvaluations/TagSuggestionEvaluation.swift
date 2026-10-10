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

struct TagSuggestionEvaluationNotes {
    static let criteria = [
        "Tags are relevant to the diary entry.",
        "Tags are lowercase, concise, and non-diagnostic.",
        "Generated tags avoid advice and full sentences."
    ]
}
#endif
