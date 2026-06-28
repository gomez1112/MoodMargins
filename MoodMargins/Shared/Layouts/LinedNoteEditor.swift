//
//  LinedNoteEditor.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import SwiftUI

struct LinedNoteEditor: View {
    @Binding var text: String

    let prompt: String
    let lines: Int
    var lineColor = PastelTheme.lavenderLine
    var textColor = Color.primary.opacity(0.82)
    var minimumHeight: CGFloat? = nil

    private let rowHeight: CGFloat = 31
    private let textLineSpacing: CGFloat = 11
    private let firstRuleOffset: CGFloat = 27

    var body: some View {
        ZStack(alignment: .topLeading) {
            LinedNoteRules(
                lines: lines,
                rowHeight: rowHeight,
                firstRuleOffset: firstRuleOffset,
                lineColor: lineColor
            )

            TextField(prompt, text: $text, axis: .vertical)
                .font(.system(.body, design: .serif))
                .foregroundStyle(textColor)
                .lineSpacing(textLineSpacing)
                .lineLimit(lines, reservesSpace: true)
                .frame(minHeight: minimumHeight ?? CGFloat(lines) * rowHeight, alignment: .topLeading)
                .padding(.top, 1)
        }
    }
}

#Preview {
    LinedNoteEditor(
        text: .constant("Dear diary,\nThe line spacing now keeps text above each rule."),
        prompt: "Write a little about today...",
        lines: 5
    )
    .padding()
    .background(PastelTheme.background)
}
