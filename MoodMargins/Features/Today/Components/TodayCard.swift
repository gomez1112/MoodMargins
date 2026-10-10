import SwiftUI

struct TodayCard: View {
    @Environment(\.diaryPalette) private var palette
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Bindable var viewModel: TodayViewModel
    var lines = 3

    var body: some View {
        DiaryCard(rotation: .zero) {
            VStack(alignment: .leading, spacing: 16) {
                header
                LinedNote(text: $viewModel.note, lines: lines)
                FlowLayout(spacing: 8) {
                    if viewModel.selectedTagList.isEmpty {
                        Text("No tags yet")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.selectedTagList, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(palette.washiColor(tag).opacity(0.18), in: Capsule())
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
                .foregroundStyle(palette.ink)
            Text("\(viewModel.statusText) · \(viewModel.selectedTagList.count) tags")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

}
