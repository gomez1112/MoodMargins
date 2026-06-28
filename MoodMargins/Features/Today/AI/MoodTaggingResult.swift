//
//  MoodTaggingResult.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import Foundation

#if canImport(FoundationModels)
import FoundationModels

@Generable
struct MoodTaggingResult: Sendable, Equatable {
    @Guide(description: "Short lowercase tags that describe emotions, topics, or routines in the diary entry.", .maximumCount(4))
    let tags: [String]
}
#else
struct MoodTaggingResult: Sendable, Equatable {
    let tags: [String]
}
#endif
