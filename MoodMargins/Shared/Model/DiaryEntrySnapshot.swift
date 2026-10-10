import Foundation

/// A value snapshot makes edits to a queried model observable without retaining a second live model.
struct DiaryEntrySnapshot: Equatable {
    var id: UUID
    var date: Date
    var mood: Mood
    var note: String
    var tags: [String]

    init(_ entry: MoodEntry) {
        id = entry.id
        date = entry.date
        mood = entry.mood
        note = entry.note
        tags = entry.tags
    }
}
