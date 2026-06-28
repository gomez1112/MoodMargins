//
//  FoundationModelsAvailability.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

struct FoundationModelsAvailability: Sendable, Equatable {
    let isAvailable: Bool
    let message: String?

    static let unavailableInBuild = FoundationModelsAvailability(
        isAvailable: false,
        message: String(localized: "Apple Intelligence is not available in this build.")
    )

#if canImport(FoundationModels)
    static func current(for model: SystemLanguageModel = .default) -> FoundationModelsAvailability {
        switch model.availability {
        case .available:
            return FoundationModelsAvailability(isAvailable: true, message: nil)
        case .unavailable(let reason):
            return FoundationModelsAvailability(isAvailable: false, message: message(for: reason))
        }
    }

    private static func message(for reason: SystemLanguageModel.Availability.UnavailableReason) -> String {
        switch reason {
        case .deviceNotEligible:
            return String(localized: "This device does not support Apple Intelligence.")
        case .appleIntelligenceNotEnabled:
            return String(localized: "Apple Intelligence is not enabled.")
        case .modelNotReady:
            return String(localized: "Apple Intelligence is still preparing.")
        @unknown default:
            return String(localized: "Apple Intelligence is unavailable.")
        }
    }
#else
    static func current() -> FoundationModelsAvailability {
        unavailableInBuild
    }
#endif
}
