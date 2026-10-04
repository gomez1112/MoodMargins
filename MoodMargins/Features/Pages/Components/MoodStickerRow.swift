import SwiftUI

struct MoodStickerRow: View {
    @Bindable var viewModel: PageViewModel

    var body: some View {
        MoodPicker(selection: Binding(get: { viewModel.selectedMood }, set: viewModel.selectMood), title: String(localized: "Mood for this page"))
    }
}
