import SwiftUI

struct MoodStickerRow: View {
    @Bindable var viewModel: PageViewModel

    var body: some View {
        MoodPicker(selection: $viewModel.selectedMood, title: String(localized: "Mood for this page"))
    }
}
