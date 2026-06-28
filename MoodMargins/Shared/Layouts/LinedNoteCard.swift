//
//  LinedNoteCard.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import SwiftUI

struct LinedNoteCard: View {
    @Binding var text: String

    let prompt: String
    let lines: Int
    let paper: Color
    let lineColor: Color
    let accentColor: Color
    let saveAction: () -> Void

    var body: some View {
        LinedNoteEditor(
            text: $text,
            prompt: prompt,
            lines: lines,
            lineColor: lineColor,
            minimumHeight: 178
        )
        .padding(18)
        .background(paper, in: RoundedRectangle(cornerRadius: 18))
        .overlay(alignment: .topTrailing) {
            Image(systemName: "pencil.tip")
                .rotationEffect(.degrees(45))
                .foregroundStyle(.pink.opacity(0.5))
                .padding(12)
        }
        .overlay(alignment: .bottomTrailing) {
            Button("Save page", systemImage: "checkmark.seal.fill", action: saveAction)
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .buttonStyle(.borderedProminent)
                .tint(accentColor.opacity(0.85))
                .padding(12)
        }
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }
}

#Preview {
    LinedNoteCard(
        text: .constant("Dear diary,"),
        prompt: "Dear diary...",
        lines: 6,
        paper: PastelTheme.paper,
        lineColor: PastelTheme.lavenderLine,
        accentColor: .pink
    ) {}
    .padding()
    .background(PastelTheme.background)
}
