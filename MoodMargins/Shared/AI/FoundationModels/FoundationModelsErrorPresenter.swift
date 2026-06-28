//
//  FoundationModelsErrorPresenter.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

enum FoundationModelsAppError: Error, LocalizedError, Sendable {
    case modelUnavailable(String)
    case emptyInput

    var errorDescription: String? {
        switch self {
        case .modelUnavailable(let message):
            message
        case .emptyInput:
            String(localized: "Add more text before generating.")
        }
    }
}

enum FoundationModelsErrorPresenter {
    static func message(for error: Error) -> String {
        if let localizedError = error as? LocalizedError,
           let description = localizedError.errorDescription,
           !description.isEmpty {
            return description
        }

#if canImport(FoundationModels)
        if let languageModelError = error as? LanguageModelError {
            switch languageModelError {
            case .contextSizeExceeded:
                return String(localized: "There is too much diary context to summarize at once.")
            case .guardrailViolation:
                return String(localized: "This request could not be generated safely.")
            case .rateLimited:
                return String(localized: "Too many requests. Try again shortly.")
            case .unsupportedLanguageOrLocale:
                return String(localized: "This language is not supported by Apple Intelligence yet.")
            case .unsupportedGenerationGuide:
                return String(localized: "This generated format is not supported.")
            case .refusal:
                return String(localized: "Apple Intelligence declined to respond.")
            case .unsupportedCapability, .unsupportedTranscriptContent:
                return String(localized: "Apple Intelligence could not process this request.")
            case .timeout:
                return String(localized: "Apple Intelligence took too long to respond.")
            @unknown default:
                break
            }
        }

        if let sessionError = error as? LanguageModelSession.Error {
            switch sessionError {
            case .concurrentRequests:
                return String(localized: "Another response is still generating.")
            default:
                break
            }
        }

        if let systemModelError = error as? SystemLanguageModel.Error {
            switch systemModelError {
            case .assetsUnavailable:
                return String(localized: "Apple Intelligence is temporarily unavailable.")
            @unknown default:
                break
            }
        }
#endif

        return error.localizedDescription
    }
}
