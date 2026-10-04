//
//  WashiTags.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import SwiftUI

struct WashiTags: View {
    @Environment(\.diaryPalette) private var palette
    var viewModel: PageViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Washi tags")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(palette.ink)

            ForEach(viewModel.tagGroups) { group in
                VStack(alignment: .leading, spacing: 8) {
                    Text(group.title)
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(.secondary)
                    FlowLayout(spacing: 10) {
                        ForEach(group.tags, id: \.self) { tag in
                            WashiTagButton(tag: tag, isSelected: viewModel.tags.contains(tag)) {
                                viewModel.toggleTag(tag)
                            }
                        }
                    }
                }
            }
        }
    }
}
