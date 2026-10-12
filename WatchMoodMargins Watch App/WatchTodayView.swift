import SwiftUI

struct WatchTodayView: View {
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced
    @State private var isChoosingMood = false
    var journal: WatchJournalStore
    var isActive: Bool

    var body: some View {
        @Bindable var journal = journal

        ScrollView {
            VStack(spacing: 10) {
                Button {
                    isChoosingMood = true
                } label: {
                    WatchMoodCard(
                        mood: journal.selectedMood,
                        title: journal.hasSelectedMood ? journal.selectedMood.title : String(localized: "Choose mood"),
                        animates: isActive && !isChoosingMood,
                        showsDisclosure: true,
                        isCompact: true
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("Mood"))
                .accessibilityValue(journal.hasSelectedMood ? journal.selectedMood.title : String(localized: "Choose mood"))
                .accessibilityHint(Text("Choose mood"))
                .accessibilityIdentifier("watch-choose-mood")

                TextField("A short note", text: $journal.note)
                    .tint(WatchDiaryStyle.action)
                    .accessibilityIdentifier("watch-note")
                    .privacySensitive()

                if let error = journal.errorMessage {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundStyle(.red)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Today")
        .sheet(isPresented: $isChoosingMood) {
            NavigationStack {
                WatchMoodSelectionView(journal: journal)
            }
        }
        .disabled(isLuminanceReduced)
#if DEBUG
        .task {
            if ProcessInfo.processInfo.arguments.contains("--marketing-capture"),
               ProcessInfo.processInfo.arguments.contains("--marketing-moods") {
                isChoosingMood = true
            }
        }
#endif
    }
}
