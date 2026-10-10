import Foundation
import FoundationModels

enum FoundationModelsAppError: Error, LocalizedError, Sendable {
    case modelUnavailable(String)
    case emptyInput
    case unsupportedLanguage
    case structuredOutputUnavailable

    var errorDescription: String? {
        switch self {
        case .modelUnavailable(let message): message
        case .emptyInput: String(localized: "Add more text before generating.")
        case .unsupportedLanguage: String(localized: "The selected model does not support this language yet.")
        case .structuredOutputUnavailable: String(localized: "The selected model cannot generate journal tags or recap cards.")
        }
    }
}

enum FoundationModelsErrorPresenter {
    static func message(for error: Error) -> String {
        if let cloudError = error as? PrivateCloudComputeLanguageModel.Error {
            switch cloudError {
            case .networkFailure:
                return String(localized: "Private Cloud Compute needs an internet connection. Check your connection and try again.")
            case .quotaLimitReached(let quota):
                return FoundationModelService.quotaMessage(resetDate: quota.resetDate)
            case .serviceUnavailable:
                return String(localized: "Private Cloud Compute is temporarily unavailable. Try again later.")
            @unknown default:
                return String(localized: "Private Cloud Compute could not complete this request.")
            }
        }
        if let modelError = error as? LanguageModelError {
            switch modelError {
            case .contextSizeExceeded: return String(localized: "There is too much diary context to summarize at once.")
            case .guardrailViolation: return String(localized: "This request could not be generated safely.")
            case .rateLimited: return String(localized: "Too many requests. Try again shortly.")
            case .unsupportedLanguageOrLocale: return String(localized: "This language is not supported by the selected model yet.")
            case .unsupportedGenerationGuide: return String(localized: "This generated format is not supported.")
            case .refusal: return String(localized: "The selected model declined to respond.")
            case .unsupportedCapability, .unsupportedTranscriptContent: return String(localized: "The selected model could not process this request.")
            case .timeout: return String(localized: "The selected model took too long to respond.")
            @unknown default: break
            }
        }
        if let sessionError = error as? LanguageModelSession.Error, sessionError == .concurrentRequests {
            return String(localized: "Another response is still generating.")
        }
        if let systemError = error as? SystemLanguageModel.Error {
            switch systemError {
            case .assetsUnavailable: return String(localized: "The on-device model is temporarily unavailable.")
            @unknown default: break
            }
        }
        if let localizedError = error as? LocalizedError, let description = localizedError.errorDescription, !description.isEmpty {
            return description
        }
        return error.localizedDescription
    }
}
