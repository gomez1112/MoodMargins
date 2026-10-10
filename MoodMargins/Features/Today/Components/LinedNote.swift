//
//  LinedNote.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/21/26.
//

import SwiftUI

struct LinedNote: View {
    @Environment(\.diaryPalette) private var palette
    @Binding var text: String
    let lines: Int

    var body: some View {
        LinedNoteEditor(
            text: $text,
            prompt: "Write a little about today…",
            lines: lines,
            lineColor: palette.lavenderLine
        )
    }
}
