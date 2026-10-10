import SwiftUI

struct ThemePreviewView: View {
    var theme: DiaryTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("A page of your own")
                    .font(.system(.title3, design: .rounded).bold())
                Spacer(minLength: 8)
                Image(systemName: theme.symbol).font(.title2).accessibilityHidden(true)
            }
            .foregroundStyle(theme.palette.ink)
            VStack(alignment: .leading, spacing: 14) {
                MoodLottieIcon(mood: .wink, size: 48).accessibilityHidden(true)
                Text("A quiet moment, just for me.")
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(theme.palette.ink)
                    .fixedSize(horizontal: false, vertical: true)
                LinedNoteRules(lines: 3, rowHeight: 28, firstRuleOffset: 0, lineColor: theme.palette.lavenderLine)
                    .frame(height: 58)
                Text("#calm  #rest")
                    .font(.caption)
                    .padding(10)
                    .background(theme.palette.blush, in: Capsule())
                    .foregroundStyle(theme.palette.ink)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.palette.paper, in: .rect(cornerRadius: 18))
            HStack(spacing: 12) {
                ForEach(0..<3) { index in
                    [theme.palette.ink, theme.palette.paper, theme.palette.action][index]
                        .frame(height: 24)
                        .clipShape(.rect(cornerRadius: 8))
                }
            }
            .accessibilityHidden(true)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.palette.background, in: .rect(cornerRadius: 24))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(localized: "\(theme.title) theme preview"))
    }
}
