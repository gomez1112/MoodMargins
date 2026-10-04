import SwiftUI

struct QuickMoodCard: View {
    @Binding var selectedMood: Mood
    @Binding var pageSaved: Bool

    var body: some View {
        MoodPicker(selection: $selectedMood, title: String(localized: "Today I feel…"))
    }
}
