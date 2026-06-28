//
//  InsightRecapProvider.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import Foundation

protocol InsightRecapProviding: Sendable {
    func generateRecap(
        for snapshot: InsightRecapSnapshot,
        onPartial: @MainActor @Sendable (PartialGeneratedInsightRecap) -> Void
    ) async throws
}

extension FoundationInsightRecapProvider: InsightRecapProviding {}
