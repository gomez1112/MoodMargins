import SwiftUI

struct WatchPageDetailView: View {
    var entry: WatchJournalEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    WatchMoodAnimation(mood: entry.mood, size: 42)
                        .padding(7)
                        .background(WatchDiaryStyle.moodPaper(entry.mood), in: .circle)
                    Text(entry.mood.title)
                        .font(.headline)
                }
                if !entry.note.isEmpty {
                    Text(entry.note)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .privacySensitive()
        }
        .navigationTitle(entry.date.formatted(.dateTime.month(.abbreviated).day()))
        .toolbarTitleDisplayMode(.inline)
        .background(WatchDiaryStyle.canvas)
    }
}
