import SwiftUI

/// Horizontal browsing previews emotions; an explicit tap confirms and saves one.
struct WatchEmotionCarousel: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .body) private var stickerSize = 52.0
    @State private var focusedMood: Mood?
    @State private var selectionFeedback = 0
    var journal: WatchJournalStore
    var isActive: Bool

    init(journal: WatchJournalStore, isActive: Bool) {
        self.journal = journal
        self.isActive = isActive
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
        ScrollView(.horizontal) {
            LazyHStack(spacing: 8) {
                ForEach(Mood.allCases) { mood in
                    let isSelected = journal.hasSelectedMood && journal.selectedMood == mood
                    Button {
                        journal.selectMood(mood)
                        journal.saveIfChanged()
                        focusedMood = mood
                        selectionFeedback += 1
                    } label: {
                        VStack(spacing: 8) {
                            WatchMoodAnimation(
                                mood: mood,
                                size: min(stickerSize, 82),
                                animates: isActive && focusedMood == mood
                            )
                            .padding(8)
                            .background(WatchDiaryStyle.moodPaper(mood), in: .circle)
                            .overlay {
                                Circle()
                                    .strokeBorder(isSelected ? WatchDiaryStyle.action : .clear, lineWidth: 3)
                            }
                            .overlay(alignment: .bottomTrailing) {
                                if isSelected {
                                    Image(systemName: "checkmark")
                                        .font(.caption2.bold())
                                        .foregroundStyle(WatchDiaryStyle.ink)
                                        .padding(5)
                                        .background(WatchDiaryStyle.paper, in: .circle)
                                        .accessibilityHidden(true)
                                }
                            }
                            Text(mood.title)
                                .font(.caption.bold())
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .opacity(focusedMood == mood ? 1 : 0)
                        }
                        .frame(width: min(stickerSize, 82) + 24)
                        .padding(.vertical, 4)
                        .contentShape(.rect)
                        .scaleEffect(focusedMood == mood ? 1 : 0.85)
                    }
                    .buttonStyle(.plain)
                    .id(mood)
                    .accessibilityLabel(mood.title)
                    .accessibilityAddTraits(isSelected ? [.isSelected] : [])
                    .accessibilityIdentifier("watch-mood-\(mood.lottieFileName)")
                }
            }
            .scrollTargetLayout()
        }
        .safeAreaPadding(.horizontal, 48)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $focusedMood, anchor: .center)
        .scrollIndicators(.hidden)
        .animation(reduceMotion ? nil : .snappy, value: focusedMood)
        .sensoryFeedback(.selection, trigger: selectionFeedback)
        .onChange(of: journal.selectedMood) {
            focusedMood = journal.selectedMood
        }
    }
}
