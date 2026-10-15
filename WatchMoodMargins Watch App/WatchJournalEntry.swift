import Foundation

struct WatchJournalEntry: Codable, Identifiable, Equatable {
    var id: UUID
    var date: Date
    var mood: Mood
    var note: String
}

extension WatchJournalEntry {
    init(_ entry: MoodEntry) {
        id = entry.id
        date = entry.date
        mood = entry.mood
        note = entry.note
    }
}
