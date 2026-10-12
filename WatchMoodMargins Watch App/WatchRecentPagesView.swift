import SwiftUI

struct WatchRecentPagesView: View {
    var entries: [WatchJournalEntry]

    var body: some View {
        List {
            if entries.isEmpty {
                Text("Your check-ins will appear here.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ForEach(entries.prefix(7)) { entry in
                NavigationLink(value: entry.id) {
                    HStack(spacing: 10) {
                        WatchMoodAnimation(mood: entry.mood, size: 30, animates: false)
                            .padding(5)
                            .background(WatchDiaryStyle.moodPaper(entry.mood), in: .circle)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(entry.date, format: .dateTime.month(.abbreviated).day())
                                .font(.caption.bold())
                            Text(entry.note.isEmpty ? entry.mood.title : entry.note)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                    .padding(.vertical, 3)
                }
                .privacySensitive()
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(WatchDiaryStyle.ink.opacity(0.35))
                )
                .accessibilityIdentifier("watch-page-\(entry.id)")
            }
        }
        .navigationTitle("Recent pages")
        .toolbarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(WatchDiaryStyle.canvas)
        .navigationDestination(for: UUID.self) { id in
            if let entry = entries.first(where: { $0.id == id }) {
                WatchPageDetailView(entry: entry)
            }
        }
    }
}
