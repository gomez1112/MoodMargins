import SwiftUI

struct PageTagEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.diaryPalette) private var palette
    var viewModel: PageViewModel
    @State private var customTags: [String]

    init(viewModel: PageViewModel) {
        self.viewModel = viewModel
        let presets = Set(viewModel.tagGroups.flatMap(\.tags))
        // Keep these choices available for the sheet's lifetime so removing a tag can be undone.
        _customTags = State(initialValue: viewModel.selectedTagList.filter { !presets.contains($0) })
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("pageTagPurpose").foregroundStyle(.secondary)
                }
                if !customTags.isEmpty {
                    Section("pageOtherTags") {
                        ForEach(customTags, id: \.self) { tag in
                            tagToggle(tag)
                        }
                    }
                }
                ForEach(viewModel.tagGroups) { group in
                    Section(group.title) {
                        ForEach(group.tags, id: \.self) { tag in
                            tagToggle(tag)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(palette.background.ignoresSafeArea())
            .navigationTitle("pageEditTags")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close", systemImage: "xmark") { dismiss() }
                        .labelStyle(.iconOnly)
                }
            }
        }
        .tint(palette.action)
    }

    private func tagToggle(_ tag: String) -> some View {
        // Read during view evaluation so Observation refreshes the toggle after a change.
        let isSelected = viewModel.tags.contains(tag)
        return Toggle(isOn: Binding {
            isSelected
        } set: { isSelected in
            if isSelected != viewModel.tags.contains(tag) { viewModel.toggleTag(tag) }
        }) {
            HStack {
                Text(tag)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(palette.action)
                        .accessibilityHidden(true)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .contentShape(.rect)
        }
        .toggleStyle(.button)
        .buttonStyle(.plain)
        .accessibilityLabel(tag)
        .accessibilityIdentifier("pageTag-\(tag)")
    }
}
