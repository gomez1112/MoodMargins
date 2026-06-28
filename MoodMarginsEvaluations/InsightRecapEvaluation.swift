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

@available(iOS 27.0, macOS 27.0, visionOS 27.0, watchOS 27.0, *)
struct InsightRecapEvaluationNotes {
    static let criteria = [
        "Recap claims are grounded in the supplied snapshot.",
        "Tone is gentle and reflective without diagnosis or prescription.",
        "The next prompt is short, useful, and not leading."
    ]
}
#endif
