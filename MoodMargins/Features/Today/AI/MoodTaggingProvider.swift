//
//  MoodTaggingProvider.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import Foundation

struct MoodTaggingRequest: Sendable, Equatable {
    let note: String
    let selectedTags: Set<String>
    let maximumTagCount: Int

    init(note: String, selectedTags: Set<String> = [], maximumTagCount: Int = 4) {
        self.note = note
        self.selectedTags = selectedTags
        self.maximumTagCount = maximumTagCount
    }
}

enum MoodTagFallbackSuggester {
    static func suggestions(for request: MoodTaggingRequest) -> [String] {
        let normalizedNote = request.note
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()

        guard normalizedNote.trimmingCharacters(in: .whitespacesAndNewlines).count >= 12 else {
            return []
        }

        let tagKeywords: [(tag: String, keywords: [String])] = [
            ("calm", ["calm", "quiet", "peace", "peaceful", "soft", "steady", "settled", "relaxed", "gentle"]),
            ("grateful", ["grateful", "gratitude", "thankful", "appreciate", "lucky"]),
            ("work", ["work", "meeting", "deadline", "project", "office", "coworker", "client", "email"]),
            ("outdoors", ["outside", "outdoors", "walk", "walking", "park", "sun", "rain", "garden", "fresh air"]),
            ("food", ["cook", "cooking", "dinner", "lunch", "breakfast", "meal", "food", "coffee", "tea"]),
            ("family", ["family", "mom", "dad", "parent", "sibling", "partner", "kid", "kids", "children"]),
            ("friends", ["friend", "friends", "social", "hangout", "called", "texted"]),
            ("rest", ["rest", "sleep", "nap", "tired", "bed", "slow", "recharge"]),
            ("stress", ["stress", "stressed", "scattered", "overwhelmed", "difficult", "hard", "worried", "anxious", "tense"]),
            ("health", ["health", "doctor", "medicine", "body", "ache", "pain", "sick", "therapy"]),
            ("creative", ["write", "writing", "draw", "drawing", "music", "paint", "creative", "made", "craft"]),
            ("home", ["home", "clean", "laundry", "room", "kitchen", "chores"])
        ]

        let scoredTags = tagKeywords.compactMap { candidate -> (tag: String, score: Int)? in
            let score = candidate.keywords.reduce(0) { partial, keyword in
                partial + (normalizedNote.contains(keyword) ? 1 : 0)
            }
            return score > 0 ? (candidate.tag, score) : nil
        }
        .sorted {
            if $0.score == $1.score {
                return $0.tag < $1.tag
            }
            return $0.score > $1.score
        }
        .map(\.tag)

        return MoodTagNormalizer.normalizedTags(
            scoredTags,
            excluding: request.selectedTags,
            limit: request.maximumTagCount
        )
    }
}

enum MoodTagNormalizer {
    static func normalizedTags(_ tags: [String], excluding selectedTags: Set<String> = [], limit: Int = 4) -> [String] {
        let selected = Set(selectedTags.map(normalizedTag).filter { !$0.isEmpty })
        var seen: Set<String> = []
        var normalized: [String] = []

        for tag in tags {
            let candidate = normalizedTag(tag)
            guard !candidate.isEmpty, !selected.contains(candidate), !seen.contains(candidate) else { continue }
            seen.insert(candidate)
            normalized.append(candidate)

            if normalized.count == limit {
                break
            }
        }

        return normalized
    }

    static func normalizedTag(_ tag: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(.whitespaces).union(CharacterSet(charactersIn: "-_"))
        let scalars = tag
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "#"))
            .lowercased()
            .unicodeScalars
            .filter { allowed.contains($0) }

        return String(String.UnicodeScalarView(scalars))
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
    }
}
