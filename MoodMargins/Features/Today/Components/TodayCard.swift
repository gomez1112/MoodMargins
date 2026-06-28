//
//  TodayCard.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/27/26.
//

import SwiftUI

struct TodayCard: View {
    @Bindable var viewModel: TodayViewModel
    let saveAction: () -> Void

    var body: some View {
        DiaryCard(rotation: .degrees(-1.5)) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Today's page")
                            .font(.system(.headline, design: .rounded))
                            .foregroundStyle(PastelTheme.ink)
                        Text("\(viewModel.statusText) · \(viewModel.selectedTagList.count) tags")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button(viewModel.saveButtonTitle, systemImage: viewModel.pageSaved && !viewModel.hasPendingChanges ? "checkmark.seal" : "checkmark.seal.fill", action: saveAction)
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .buttonStyle(.borderedProminent)
                        .tint(viewModel.selectedMood.tint.opacity(viewModel.hasPendingChanges ? 0.85 : 0.35))
                        .disabled(!viewModel.hasPendingChanges)
                }

                LinedNote(text: $viewModel.note, lines: 3)

                FlowLayout(spacing: 8) {
                    if viewModel.selectedTagList.isEmpty {
                        Text("Add a washi tag above")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.selectedTagList.prefix(4), id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.system(.caption, design: .rounded).weight(.medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(Capsule().fill(PastelTheme.washiColor(tag).opacity(0.75)))
                                .foregroundStyle(.white)
                        }

                        if viewModel.hiddenSelectedTagCount > 0 {
                            Text("+\(viewModel.hiddenSelectedTagCount) more")
                                .font(.system(.caption, design: .rounded).weight(.semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(Capsule().fill(.white.opacity(0.62)))
                                .foregroundStyle(PastelTheme.ink)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    TodayCard(viewModel: TodayViewModel()) {}
}
