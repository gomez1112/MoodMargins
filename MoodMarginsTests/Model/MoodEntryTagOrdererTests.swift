//
//  MoodEntryTagOrdererTests.swift
//  MoodMarginsTests
//
//  Created by Gerard Gomez on 6/28/26.
//

import Testing
@testable import MoodMargins

@Suite("Mood entry tag ordering", .serialized)
@MainActor
struct MoodEntryTagOrdererTests {
    @Test("Known tags preserve the provided display order")
    func knownTagsPreserveDisplayOrder() {
        let orderedTags = MoodEntryTagOrderer.orderedTags(
            selectedTags: ["rest", "calm", "grateful"],
            knownTags: ["grateful", "tired", "calm", "work", "rest"],
            includesCustomTags: false
        )

        #expect(orderedTags == ["grateful", "calm", "rest"])
    }

    @Test("Unknown tags are ignored when custom tags are disabled")
    func unknownTagsAreIgnoredWhenCustomTagsAreDisabled() {
        let orderedTags = MoodEntryTagOrderer.orderedTags(
            selectedTags: ["calm", "custom", "work"],
            knownTags: ["calm", "work"],
            includesCustomTags: false
        )

        #expect(orderedTags == ["calm", "work"])
    }

    @Test("Unknown tags are sorted and appended when custom tags are enabled")
    func unknownTagsAreSortedAndAppendedWhenCustomTagsAreEnabled() {
        let orderedTags = MoodEntryTagOrderer.orderedTags(
            selectedTags: ["zine", "calm", "apple", "work"],
            knownTags: ["calm", "work"],
            includesCustomTags: true
        )

        #expect(orderedTags == ["calm", "work", "apple", "zine"])
    }
}
