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
                NavigationLink {
                    WatchPageDetailView(entry: entry)
                } label: {
                    HStack(spacing: 10) {
                        WatchMoodAnimation(mood: entry.mood, size: 34, animates: false)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.date, format: .dateTime.month(.abbreviated).day())
                                .font(.headline)
                            Text(entry.note.isEmpty ? entry.mood.title : entry.note)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                }
                .privacySensitive()
                .accessibilityIdentifier("watch-page-\(entry.id)")
            }
        }
        .navigationTitle("Recent pages")
    }
}
