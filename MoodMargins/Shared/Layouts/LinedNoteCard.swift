import SwiftUI

struct LinedNoteCard: View {
    @Binding var text: String
    var prompt: String
    var lines: Int
    var paper: Color
    var lineColor: Color
    var accentColor: Color
    var saveAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            LinedNoteEditor(text: $text, prompt: prompt, lines: lines, lineColor: lineColor, minimumHeight: 178)
            HStack {
                Spacer()
                Button("Save page", systemImage: "checkmark.seal.fill", action: saveAction)
                    .buttonStyle(.borderedProminent)
                    .tint(PastelTheme.action)
            }
        }
        .padding(18)
        .background(paper, in: .rect(cornerRadius: 18))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }
}
