import SwiftUI

struct WatchTodayView: View {
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced
    var journal: WatchJournalStore
    var isActive: Bool

    var body: some View {
        @Bindable var journal = journal

        ScrollView {
            VStack(spacing: 10) {
                WatchEmotionCarousel(journal: journal, isActive: isActive)
                    .accessibilityIdentifier("watch-emotions")

                TextField("A short note", text: $journal.note)
                    .accessibilityIdentifier("watch-note")
                    .privacySensitive()

                if let error = journal.errorMessage {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundStyle(.red)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.bottom, 12)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Today")
        .toolbarTitleDisplayMode(.inline)
        .background(WatchDiaryStyle.canvas)
        .disabled(isLuminanceReduced)
    }
}
