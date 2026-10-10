import SwiftUI

struct WatchTodayView: View {
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced
    @State private var isChoosingMood = false
    var journal: WatchJournalStore
    var isActive: Bool

    var body: some View {
        @Bindable var journal = journal

        ScrollView {
            VStack(spacing: 14) {
                Button {
                    isChoosingMood = true
                } label: {
                    VStack(spacing: 6) {
                        WatchMoodAnimation(mood: journal.selectedMood, size: 72, animates: isActive && !isChoosingMood)
                        Text(journal.hasSelectedMood ? journal.selectedMood.title : String(localized: "Mood"))
                            .font(.headline)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("Mood"))
                .accessibilityValue(journal.hasSelectedMood ? journal.selectedMood.title : String(localized: "Choose mood"))
                .accessibilityHint(Text("Choose mood"))
                .accessibilityIdentifier("watch-choose-mood")

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
            .padding(.horizontal)
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
    }
}
