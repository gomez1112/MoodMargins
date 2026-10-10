import Foundation
import FoundationModels

struct FoundationInsightRecapProvider: Sendable {
    func generateRecap(for snapshot: InsightRecapSnapshot, onPartial: @MainActor @Sendable (PartialGeneratedInsightRecap) -> Void) async throws {
        try await FoundationModelFallback.run(preferred: snapshot.modelChoice) { choice in
            onPartial(.empty)
            try await generateRecap(for: snapshot, using: choice, onPartial: onPartial)
        }
    }

    private func generateRecap(for snapshot: InsightRecapSnapshot, using choice: FoundationModelChoice, onPartial: @MainActor @Sendable (PartialGeneratedInsightRecap) -> Void) async throws {
        let session = try await FoundationModelService.session(
            choice: choice,
            contentTagging: false,
            instructions: "You create concise MoodMargins recap cards. Ground every claim in provided entries. Do not diagnose, prescribe, or infer health conditions. Describe emotions in words rather than unexplained numeric averages."
        )
        let stream = session.streamResponse(
            to: Prompt(snapshot.promptText),
            generating: GeneratedInsightRecap.self,
            options: GenerationOptions(samplingMode: .greedy, maximumResponseTokens: 280),
            contextOptions: ContextOptions(includeSchemaInPrompt: true)
        )
        for try await partial in stream {
            try Task.checkCancellation()
            onPartial(PartialGeneratedInsightRecap(partial.content))
        }
    }
}
