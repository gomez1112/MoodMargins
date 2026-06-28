//
//  Activity.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/21/26.
//

import Foundation
import SwiftData

@Model
final class Activity: Identifiable {
    var id = UUID()
    var title = ""
    var symbol = ""
    var moodEntry: MoodEntry?
    
    init(title: String, symbol: String) {
        self.title = title
        self.symbol = symbol
    }
    @MainActor static let library: [Activity] = [
        Activity(title: String(localized: "Work"),     symbol: "laptopcomputer"),
        Activity(title: String(localized: "Exercise"), symbol: "figure.run"),
        Activity(title: String(localized: "Social"),   symbol: "person.2.fill"),
        Activity(title: String(localized: "Family"),   symbol: "house.fill"),
        Activity(title: String(localized: "Reading"),  symbol: "book.fill"),
        Activity(title: String(localized: "Music"),    symbol: "music.note"),
        Activity(title: String(localized: "Outdoors"), symbol: "leaf.fill"),
        Activity(title: String(localized: "Rest"),     symbol: "bed.double.fill"),
        Activity(title: String(localized: "Food"),     symbol: "fork.knife"),
        Activity(title: String(localized: "Travel"),   symbol: "airplane")
    ]
}
