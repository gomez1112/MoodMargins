import SwiftUI

/// Spatial windows retain the system's adaptive glass; other platforms use notebook colors.
struct DiaryWindowBackground: View {
    @Environment(\.diaryPalette) private var palette

    var body: some View {
#if os(visionOS)
        Color.clear
#else
        palette.background.ignoresSafeArea()
#endif
    }
}
