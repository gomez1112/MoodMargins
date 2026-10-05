//
//  LinedNoteEditor.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import SwiftUI

struct LinedNoteEditor: View {
    @Environment(\.diaryPalette) private var palette
    @Binding var text: String
    @FocusState private var isFocused: Bool

    let prompt: String
    let lines: Int
    var lineColor: Color? = nil
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
                lineColor: lineColor ?? palette.lavenderLine
            )

            TextField(prompt, text: $text, axis: .vertical)
                .accessibilityIdentifier("journal-note")
                .focused($isFocused)
                .textFieldStyle(.plain)
                .font(.system(.body, design: .serif))
                .foregroundStyle(textColor)
                .lineSpacing(textLineSpacing)
                .lineLimit(lines, reservesSpace: true)
                .frame(minHeight: minimumHeight ?? CGFloat(lines) * rowHeight, alignment: .topLeading)
                .padding(.top, 1)
        }
#if os(iOS)
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done", systemImage: "keyboard.chevron.compact.down") {
                    isFocused = false
                }
                .accessibilityIdentifier("dismiss-journal-keyboard")
            }
        }
#endif
    }
}
