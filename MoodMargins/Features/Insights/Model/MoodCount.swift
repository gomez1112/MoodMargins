//
//  MoodCount.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/27/26.
//


struct MoodCount: Identifiable {
    var id: Int { mood.rawValue }
    let mood: Mood
    let count: Int
}