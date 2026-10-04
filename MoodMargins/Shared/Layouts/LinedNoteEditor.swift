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

    @ScaledMetric(relativeTo: .body) private var rowHeight = 31.0
    private let textLineSpacing: CGFloat = 11
    @ScaledMetric(relativeTo: .body) private var firstRuleOffset = 27.0

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
