//
//  InsightRecapEvaluation.swift
//  MoodMarginsEvaluations
//
//  Created by Gerard Gomez on 6/28/26.
//

import Foundation

#if canImport(Evaluations) && canImport(FoundationModels)
import Evaluations
import FoundationModels

struct InsightRecapEvaluationNotes {
    static let criteria = [
        "Recap claims are grounded in the supplied snapshot.",
        "Tone is gentle and reflective without diagnosis or prescription.",
        "The next prompt is short, useful, and not leading."
    ]
}
#endif
