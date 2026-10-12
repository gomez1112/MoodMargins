import SwiftUI

struct WatchMoodSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var focusedMood: Mood
    var journal: WatchJournalStore

    init(journal: WatchJournalStore) {
        self.journal = journal
        var initialMood = journal.selectedMood
#if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--marketing-capture"),
           let index = arguments.firstIndex(of: "--marketing-focus"),
           arguments.indices.contains(index + 1),
           let rating = Int(arguments[index + 1]),
           let mood = Mood(rawValue: rating) {
            initialMood = mood
        }
#endif
        _focusedMood = State(initialValue: initialMood)
    }

    var body: some View {
        TabView(selection: $focusedMood) {
            ForEach(Mood.allCases) { mood in
                Button {
                    journal.selectMood(mood)
                    journal.saveIfChanged()
                    dismiss()
                } label: {
                    WatchMoodCard(
                        mood: mood,
                        title: mood.title,
                        animates: focusedMood == mood,
                        isSelected: journal.hasSelectedMood && journal.selectedMood == mood
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(.rect)
                    .padding(.horizontal, 6)
                    .padding(.bottom, 22)
                }
                .buttonStyle(.plain)
                .tag(mood)
                .accessibilityLabel(mood.title)
                .accessibilityAddTraits(journal.hasSelectedMood && journal.selectedMood == mood ? [.isSelected] : [])
                .accessibilityIdentifier("watch-mood-\(mood.lottieFileName)")
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .navigationTitle("Mood")
        .sensoryFeedback(.selection, trigger: focusedMood)
    }
}
