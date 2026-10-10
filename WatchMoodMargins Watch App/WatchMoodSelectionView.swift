import SwiftUI

struct WatchMoodSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    var journal: WatchJournalStore

    var body: some View {
        List(Mood.allCases) { mood in
            Button {
                journal.selectMood(mood)
                journal.saveIfChanged()
                dismiss()
            } label: {
                HStack(spacing: 10) {
                    WatchMoodAnimation(mood: mood, size: 40, animates: journal.hasSelectedMood && journal.selectedMood == mood)
                    Text(mood.title)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                    if journal.hasSelectedMood && journal.selectedMood == mood {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.tint)
                            .accessibilityHidden(true)
                    }
                }
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(mood.title)
            .accessibilityAddTraits(journal.hasSelectedMood && journal.selectedMood == mood ? [.isSelected] : [])
            .accessibilityIdentifier("watch-mood-\(mood.lottieFileName)")
        }
        .navigationTitle("Mood")
        .sensoryFeedback(.selection, trigger: journal.selectedMood)
    }
}
