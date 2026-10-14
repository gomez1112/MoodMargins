import SwiftUI

struct LinedNoteCard: View {
    @Environment(\.diaryPalette) private var palette
    @Binding var text: String
    var prompt: String
    var lines: Int
    var paper: Color
    var lineColor: Color
    var accentColor: Color
    var saveStatus: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            LinedNoteEditor(text: $text, prompt: prompt, lines: lines, lineColor: lineColor, minimumHeight: 178)
            Text(saveStatus).font(.caption).foregroundStyle(palette.softInk)
        }
        .padding(18)
        .diarySurface(paper: paper)
    }
}
