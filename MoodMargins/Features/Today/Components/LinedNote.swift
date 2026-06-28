//
//  LinedNote.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/21/26.
//

import SwiftUI

struct LinedNote: View {
    @Binding var text: String
    let lines: Int

    var body: some View {
        LinedNoteEditor(
            text: $text,
            prompt: "Write a little about today...",
            lines: lines,
            lineColor: PastelTheme.lavenderLine
        )
    }
}

#Preview {
    LinedNote(text: .constant("Hello, I love this very much."), lines: 8)
}
