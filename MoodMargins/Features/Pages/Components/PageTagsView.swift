import SwiftUI

/// Shows the saved page's labels without making the optional tag picker part of the page.
struct PageTagsView: View {
    @Environment(\.diaryPalette) private var palette
    var viewModel: PageViewModel
    @State private var isEditingTags = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if !viewModel.tags.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(viewModel.selectedTagList.prefix(3), id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption)
                            .lineLimit(1)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(palette.washiColor(tag).opacity(0.18), in: Capsule())
                    }
                    if viewModel.tags.count > 3 {
                        Text("+\(viewModel.tags.count - 3)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            Button("pageEditTags", systemImage: "tag.fill") { isEditingTags = true }
                .font(.subheadline)
                .frame(minHeight: 44)
                .accessibilityIdentifier("pageEditTags")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .sheet(isPresented: $isEditingTags) {
            PageTagEditorView(viewModel: viewModel)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}
