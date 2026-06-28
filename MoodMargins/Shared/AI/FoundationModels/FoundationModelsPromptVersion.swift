//
//  FoundationModelsPromptVersion.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import Foundation

enum FoundationModelsPromptVersion: Sendable, Equatable {
    case model26Initial
    case model26Point4OrNewer

    static var current: FoundationModelsPromptVersion {
        if #available(iOS 26.4, macOS 26.4, visionOS 26.4, *) {
            return .model26Point4OrNewer
        }
        return .model26Initial
    }
}
