import SwiftUI

struct DiarySurface: ViewModifier {
    @Environment(\.diaryPalette) private var palette
    var cornerRadius: CGFloat
    var paper: Color?

    func body(content: Content) -> some View {
#if os(visionOS)
        content
            .background(.regularMaterial, in: .rect(cornerRadius: cornerRadius))
#else
        content
            .background(paper ?? palette.paper, in: .rect(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
#endif
    }
}

extension View {
    func diarySurface(cornerRadius: CGFloat = 18, paper: Color? = nil) -> some View {
        modifier(DiarySurface(cornerRadius: cornerRadius, paper: paper))
    }
}
