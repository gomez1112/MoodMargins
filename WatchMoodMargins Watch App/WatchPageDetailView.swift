import SwiftUI

struct WatchPageDetailView: View {
    var entry: WatchJournalEntry

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                WatchMoodAnimation(mood: entry.mood, size: 64)
                Text(entry.mood.title).font(.headline)
                if !entry.note.isEmpty {
                    Text(entry.note)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
            .frame(maxWidth: .infinity)
            .privacySensitive()
        }
        .navigationTitle(entry.date.formatted(.dateTime.month(.abbreviated).day()))
    }
}
