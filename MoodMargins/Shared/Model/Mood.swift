//
//  Mood.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/21/26.
//

import Foundation
import SwiftUI

enum Mood: Int, CaseIterable, Identifiable, Comparable, Codable {
    case angry = 1
    case sad
    case mourn
    case wink
    case laughing
    
    var id: Self { self }
    
    static let stateMachineID = "interactive_slider"
    static let ratingInputName = "rating"
    
    var title: String {
        switch self {
            case .angry: String(localized: "Angry")
            case .sad: String(localized: "Sad")
            case .mourn: String(localized: "Mourn")
            case .wink: String(localized: "Wink")
            case .laughing: String(localized: "Laughing")
        }
    }
    
    var lottieFileName: String {
        switch self {
            case .angry: "angry"
            case .sad: "sad"
            case .mourn: "mourn"
            case .wink: "wink"
            case .laughing: "laughing"
        }
    }
    
    var systemImage: String {
        switch self {
            case .angry: "angry.face"
            case .sad: "sad.face"
            case .mourn: "skull"
            case .wink: "smiling.face.fill"
            case .laughing: "laughing.face"
        }
    }
    var tint: Color {
        switch self {
            case .angry: return Color(red: 0.85, green: 0.26, blue: 0.30)
            case .sad:   return Color(red: 0.95, green: 0.55, blue: 0.27)
            case .mourn:  return Color(red: 0.95, green: 0.80, blue: 0.30)
            case .wink:  return Color(red: 0.45, green: 0.78, blue: 0.50)
            case .laughing: return Color(red: 0.30, green: 0.66, blue: 0.85)
        }
    }
    static func < (lhs: Mood, rhs: Mood) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
