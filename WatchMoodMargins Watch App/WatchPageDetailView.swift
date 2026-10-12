import SwiftUI

struct WatchPageDetailView: View {
    var entry: WatchJournalEntry

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                WatchMoodCard(mood: entry.mood, title: entry.mood.title)
                if !entry.note.isEmpty {
                    Text(entry.note)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundStyle(WatchDiaryStyle.ink)
                        .padding(14)
                        .background(WatchDiaryStyle.paper, in: .rect(cornerRadius: 20))
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity)
            .privacySensitive()
        }
        .navigationTitle(entry.date.formatted(.dateTime.month(.abbreviated).day()))
    }
}
