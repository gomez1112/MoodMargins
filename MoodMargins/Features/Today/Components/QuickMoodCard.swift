import SwiftUI

struct QuickMoodCard: View {
    var viewModel: TodayViewModel

    var body: some View {
        MoodPicker(selection: Binding(get: { viewModel.selectedMood }, set: viewModel.selectMood), title: String(localized: "Today I feel…"))
    }
}
