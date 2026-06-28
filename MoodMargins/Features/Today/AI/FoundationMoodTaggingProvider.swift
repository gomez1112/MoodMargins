//
//  FoundationMoodTaggingProvider.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

struct FoundationMoodTaggingProvider: Sendable {
    func generateSuggestions(
        for request: MoodTaggingRequest,
        onPartial: @MainActor @Sendable ([String]) -> Void
    ) async throws {
        let note = request.note.trimmingCharacters(in: .whitespacesAndNewlines)
        guard note.count >= 12 else {
            onPartial([])
            return
        }

#if canImport(FoundationModels)
        let model = SystemLanguageModel(useCase: .contentTagging)
        let availability = FoundationModelsAvailability.current(for: model)
        guard availability.isAvailable else {
            onPartial(MoodTagFallbackSuggester.suggestions(for: request))
            return
        }

        do {
            let session = LanguageModelSession(
                model: model,
                instructions: Instructions(Self.instructions)
            )

            let stream = session.streamResponse(
                to: Prompt(note),
                generating: MoodTaggingResult.self,
                options: GenerationOptions(samplingMode: .greedy, maximumResponseTokens: 80)
            )

            var didEmitSuggestions = false
            for try await partialResponse in stream {
                guard !Task.isCancelled else { return }
                let suggestions = MoodTagNormalizer.normalizedTags(
                    partialResponse.content.tags ?? [],
                    excluding: request.selectedTags,
                    limit: request.maximumTagCount
                )

                guard !suggestions.isEmpty else { continue }
                didEmitSuggestions = true
                onPartial(suggestions)
            }

            if !didEmitSuggestions {
                onPartial(MoodTagFallbackSuggester.suggestions(for: request))
            }
        } catch {
            guard !Task.isCancelled else { return }
            onPartial(MoodTagFallbackSuggester.suggestions(for: request))
        }
#else
        onPartial(MoodTagFallbackSuggester.suggestions(for: request))
#endif
    }

    private static var instructions: String {
        switch FoundationModelsPromptVersion.current {
        case .model26Initial:
            return "Provide up to four concise lowercase diary tags. Focus on emotions, topics, and daily routines. Do not include medical or diagnostic terms."
        case .model26Point4OrNewer:
            return "Provide up to four concise lowercase diary tags from this entry. Prefer emotions, topics, and routines. Avoid diagnosis, advice, and full sentences."
        }
    }
}
