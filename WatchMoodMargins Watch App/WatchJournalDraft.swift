import Foundation

struct WatchJournalDraft: Hashable {
    var date: Date
    var mood: Mood
    var note: String
    var confirmedMood: Bool
}
