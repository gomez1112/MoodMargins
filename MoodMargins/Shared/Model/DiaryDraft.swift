import Foundation

/// A value identity for view-owned, cancellable autosave work.
struct DiaryDraft: Hashable {
    var date: Date
    var mood: Mood
    var note: String
    var tags: Set<String>
    var confirmedMood: Bool
}
