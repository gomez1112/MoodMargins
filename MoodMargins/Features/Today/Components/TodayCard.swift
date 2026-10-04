import SwiftUI

struct TodayCard: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Bindable var viewModel: TodayViewModel
    var saveAction: () -> Void

    var body: some View {
        DiaryCard(rotation: .zero) {
            VStack(alignment: .leading, spacing: 16) {
                if dynamicTypeSize.isAccessibilitySize {
                    VStack(alignment: .leading, spacing: 12) {
                        header
                        saveButton
                    }
                } else {
                    HStack(alignment: .top) {
                        header
                        Spacer()
                        saveButton.fixedSize(horizontal: true, vertical: false)
                    }
                }
                LinedNote(text: $viewModel.note, lines: 3)
                FlowLayout(spacing: 8) {
                    if viewModel.selectedTagList.isEmpty {
                        Text("Choose a suggested tag after writing")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.selectedTagList, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(PastelTheme.washiColor(tag).opacity(0.18), in: Capsule())
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Today's page")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(PastelTheme.ink)
            Text("\(viewModel.statusText) · \(viewModel.selectedTagList.count) tags")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var saveButton: some View {
        Button(viewModel.saveButtonTitle, systemImage: "checkmark.seal.fill", action: saveAction)
            .buttonStyle(.borderedProminent)
            .tint(PastelTheme.action)
            .disabled(!viewModel.hasPendingChanges)
    }
}
