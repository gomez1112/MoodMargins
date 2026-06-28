//
//  MoodEntryTagOrderer.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import Foundation

enum MoodEntryTagOrderer {
    static func orderedTags(selectedTags: Set<String>, knownTags: [String], includesCustomTags: Bool) -> [String] {
        let orderedTags = knownTags.filter { selectedTags.contains($0) }
        guard includesCustomTags else { return orderedTags }

        let customTags = selectedTags.subtracting(knownTags).sorted()
        return orderedTags + customTags
    }
}
