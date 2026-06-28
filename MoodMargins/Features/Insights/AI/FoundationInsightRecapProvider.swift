//
//  FoundationInsightRecapProvider.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

struct FoundationInsightRecapProvider: Sendable {
    func generateRecap(
        for snapshot: InsightRecapSnapshot,
        onPartial: @MainActor @Sendable (PartialGeneratedInsightRecap) -> Void
    ) async throws {
#if canImport(FoundationModels)
        let model = SystemLanguageModel.default
        let availability = FoundationModelsAvailability.current(for: model)
        guard availability.isAvailable else {
            throw FoundationModelsAppError.modelUnavailable(availability.message ?? String(localized: "Apple Intelligence is unavailable."))
        }

        let session = LanguageModelSession(
            model: model,
            instructions: Instructions(Self.instructions)
        )

        let stream = session.streamResponse(
            to: Prompt(snapshot.promptText),
            generating: GeneratedInsightRecap.self,
            options: GenerationOptions(samplingMode: .greedy, maximumResponseTokens: 280)
        )

        for try await partialResponse in stream {
            guard !Task.isCancelled else { return }
            onPartial(PartialGeneratedInsightRecap(partialResponse.content))
        }
#else
        throw FoundationModelsAppError.modelUnavailable(String(localized: "Apple Intelligence is not available in this build."))
#endif
    }

    private static var instructions: String {
        switch FoundationModelsPromptVersion.current {
        case .model26Initial:
            return "You write short, grounded mood journal recaps. Use only provided data. Stay gentle and non-diagnostic."
        case .model26Point4OrNewer:
            return "You create concise MoodMargins recap cards. Ground every claim in provided entries. Do not diagnose, prescribe, or infer health conditions."
        }
    }
}
