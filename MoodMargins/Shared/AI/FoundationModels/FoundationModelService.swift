import Foundation
import FoundationModels

/// Builds fresh sessions for an individual model attempt; providers handle cloud-to-local retries.
@MainActor
enum FoundationModelService {
    static let cloudModel = PrivateCloudComputeLanguageModel()
    private static let taggingModel = SystemLanguageModel(useCase: .contentTagging)
    private static let generalModel = SystemLanguageModel.default

    static func status(for choice: FoundationModelChoice) -> String? {
        switch choice {
        case .onDevice:
            switch generalModel.availability {
            case .available: return nil
            case .unavailable(.deviceNotEligible): return String(localized: "This device does not support on-device Apple Intelligence.")
            case .unavailable(.appleIntelligenceNotEnabled): return String(localized: "Enable Apple Intelligence in system settings to use this model.")
            case .unavailable(.modelNotReady): return String(localized: "The on-device model is still preparing.")
            @unknown default: return String(localized: "The on-device model is unavailable.")
            }
        case .privateCloudCompute:
            switch cloudModel.availability {
            case .available:
                let quota = cloudModel.quotaUsage
                if quota.isLimitReached { return quotaMessage(resetDate: quota.resetDate) }
                if case .belowLimit(let usage) = quota.status, usage.isApproachingLimit {
                    return String(localized: "You're approaching your Private Cloud Compute limit.")
                }
                return nil
            case .unavailable(.deviceNotEligible): return String(localized: "This device cannot use Private Cloud Compute.")
            case .unavailable(.systemNotReady): return String(localized: "Private Cloud Compute is still preparing.")
            @unknown default: return String(localized: "Private Cloud Compute is unavailable.")
            }
        }
    }

    static func session(choice: FoundationModelChoice, contentTagging: Bool, instructions: String) async throws -> LanguageModelSession {
        try Task.checkCancellation()
        switch choice {
        case .onDevice:
            let model = contentTagging ? taggingModel : generalModel
            guard model.isAvailable else {
                throw FoundationModelsAppError.modelUnavailable(status(for: choice) ?? String(localized: "The on-device model is unavailable."))
            }
            guard model.supportsLocale() else { throw FoundationModelsAppError.unsupportedLanguage }
            guard model.capabilities.contains(.guidedGeneration) else { throw FoundationModelsAppError.structuredOutputUnavailable }
            return LanguageModelSession(model: model, instructions: Instructions(instructions))
        case .privateCloudCompute:
            guard cloudModel.isAvailable else {
                throw FoundationModelsAppError.modelUnavailable(status(for: choice) ?? String(localized: "Private Cloud Compute is unavailable."))
            }
            let quota = cloudModel.quotaUsage
            guard !quota.isLimitReached else {
                throw FoundationModelsAppError.modelUnavailable(quotaMessage(resetDate: quota.resetDate))
            }
            guard try await cloudModel.supportsLocale() else { throw FoundationModelsAppError.unsupportedLanguage }
            try Task.checkCancellation()
            guard cloudModel.capabilities.contains(.guidedGeneration) else { throw FoundationModelsAppError.structuredOutputUnavailable }
            return LanguageModelSession(model: cloudModel, instructions: Instructions(instructions))
        }
    }

    static func quotaMessage(resetDate: Date?) -> String {
        if let resetDate {
            return String(localized: "Private Cloud Compute limit reached. Try again after \(resetDate.formatted(date: .abbreviated, time: .shortened)).")
        }
        return String(localized: "Private Cloud Compute limit reached. Try again later.")
    }
}
