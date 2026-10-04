import Foundation

struct WatchJournalEntry: Codable, Identifiable, Equatable {
    var id: UUID
    var date: Date
    var mood: Mood
    var note: String
}
