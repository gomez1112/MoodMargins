import Foundation
import FoundationModels

struct FoundationMoodTaggingProvider: Sendable {
    func generateSuggestions(for request: MoodTaggingRequest, onPartial: @MainActor @Sendable ([String]) -> Void) async throws {
        let note = request.note.trimmingCharacters(in: .whitespacesAndNewlines)
        guard note.count >= 12 else { onPartial([]); return }
        let session = try await FoundationModelService.session(
            choice: request.modelChoice,
            contentTagging: true,
            instructions: "Provide up to four concise lowercase diary tags from this entry. Prefer emotions, topics, and routines. Avoid diagnosis, advice, and full sentences."
        )
        let stream = session.streamResponse(
            to: Prompt(note),
            generating: MoodTaggingResult.self,
            options: GenerationOptions(samplingMode: .greedy, maximumResponseTokens: 80),
            contextOptions: ContextOptions(includeSchemaInPrompt: true)
        )
        for try await partial in stream {
            try Task.checkCancellation()
            onPartial(MoodTagNormalizer.normalizedTags(partial.content.tags ?? [], excluding: request.selectedTags, limit: request.maximumTagCount))
        }
    }
}
