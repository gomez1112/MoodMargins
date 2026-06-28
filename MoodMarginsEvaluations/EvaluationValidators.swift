//
//  EvaluationValidators.swift
//  MoodMarginsEvaluations
//
//  Created by Gerard Gomez on 6/28/26.
//

import Foundation

enum EvaluationValidators {
    static let blockedDiagnosticTerms = [
        "diagnosis", "diagnose", "depression", "anxiety disorder", "treatment", "prescribe", "therapy plan"
    ]

    static func validTags(_ tags: [String], maximumCount: Int = 4) -> Bool {
        guard !tags.isEmpty, tags.count <= maximumCount else { return false }
        let normalized = MoodTagNormalizer.normalizedTags(tags, limit: maximumCount)
        return normalized.count == tags.count && normalized.allSatisfy { !$0.isEmpty && $0.count <= 28 }
    }

    static func containsDiagnosticLanguage(_ fields: [String]) -> Bool {
        let joined = fields.joined(separator: " ").lowercased()
        return blockedDiagnosticTerms.contains { joined.contains($0) }
    }

    static func validRecapFields(
        title: String,
        pattern: String,
        supportingDetail: String,
        gentleReflection: String,
        nextPrompt: String
    ) -> Bool {
        let fields = [title, pattern, supportingDetail, gentleReflection, nextPrompt]
        guard fields.allSatisfy({ !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) else { return false }
        guard fields.allSatisfy({ $0.count <= 220 }) else { return false }
        return !containsDiagnosticLanguage(fields)
    }
}
