//
//  DailyMood.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/27/26.
//

import Foundation

struct DailyMood: Identifiable {
    var date: Date
    var value: Double
    /// Marks in different runs must not be connected across days without entries.
    var segmentStart: Date

    var id: Date { date }
}
