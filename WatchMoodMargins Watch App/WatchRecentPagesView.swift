import SwiftUI

struct WatchRecentPagesView: View {
    var entries: [WatchJournalEntry]

    var body: some View {
        List {
            if entries.isEmpty {
                Text("Your check-ins will appear here.")
                    .foregroundStyle(.secondary)
            }
            ForEach(entries.prefix(7)) { entry in
                NavigationLink(value: entry.id) {
                    HStack(spacing: 10) {
                        WatchMoodAnimation(mood: entry.mood, size: 40, animates: false)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.date, format: .dateTime.month(.abbreviated).day())
                                .font(.headline)
                            Text(entry.note.isEmpty ? entry.mood.title : entry.note)
                                .font(.caption)
                                .foregroundStyle(WatchDiaryStyle.ink.opacity(0.8))
                                .lineLimit(2)
                        }
                    }
                    .foregroundStyle(WatchDiaryStyle.ink)
                    .padding(.vertical, 4)
                }
                .privacySensitive()
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(WatchDiaryStyle.moodPaper(entry.mood))
                )
                .accessibilityIdentifier("watch-page-\(entry.id)")
            }
        }
        .navigationTitle("Recent pages")
        .scrollContentBackground(.hidden)
        .navigationDestination(for: UUID.self) { id in
            if let entry = entries.first(where: { $0.id == id }) {
                WatchPageDetailView(entry: entry)
            }
        }
    }
}
