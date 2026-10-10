struct InsightSummaryItem: Identifiable {
    var id: String
    var title: String
    var value: String
    var systemName: String
    var mood: Mood? = nil
}
