import SwiftUI

/// A quiet writing cue that stays beside the draft while the person writes.
struct JournalReflectionPrompt: View {
    @Environment(\.diaryPalette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("duoReflectionTitle")
                .font(.system(.caption, design: .rounded).bold())
                .accessibilityAddTraits(.isHeader)
            Text("duoReflectionPrompt")
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(palette.softInk)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
