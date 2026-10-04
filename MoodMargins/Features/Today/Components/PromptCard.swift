//
//  PromptCard.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/26/26.
//

import SwiftUI

struct PromptCard: View {
    @Environment(\.diaryPalette) private var palette
    let generatedTags: [String]
    let isGeneratingTags: Bool
    var errorMessage: String? = nil
    var retry: () -> Void = {}
    let selectGeneratedTag: (String) -> Void

    var body: some View {
        DiaryCard(rotation: .degrees(1.2)) {
            VStack(alignment: .leading, spacing: 14) {
                Label("One small thing I noticed today was…", systemImage: "sparkles")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(palette.ink)

                if let errorMessage {
                    Text(errorMessage).font(.caption).foregroundStyle(.secondary)
                    Button("Try suggestions again", systemImage: "arrow.clockwise", action: retry)
                        .buttonStyle(.bordered)
                }
                if isGeneratingTags || !generatedTags.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label(isGeneratingTags ? "Reading your page" : "Suggested from your page", systemImage: "wand.and.sparkles")
                            .font(.system(.caption, design: .rounded).weight(.semibold))
                            .foregroundStyle(.secondary)

                        FlowLayout(spacing: 8) {
                            ForEach(generatedTags, id: \.self) { tag in
                                Button {
                                    selectGeneratedTag(tag)
                                } label: {
                                    Text("#\(tag)")
                                        .font(.system(.caption, design: .rounded).weight(.semibold))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                        .frame(minHeight: 44)
                                        .background(Capsule().fill(palette.washiColor(tag).opacity(0.22)))
                                        .overlay {
                                            Capsule()
                                                .stroke(palette.washiColor(tag).opacity(0.48), lineWidth: 1)
                                        }
                                        .foregroundStyle(.primary)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Add suggested \(tag) tag")
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }
}
