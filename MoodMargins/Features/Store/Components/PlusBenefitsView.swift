import SwiftUI

struct PlusBenefitsView: View {
    @Environment(\.diaryPalette) private var palette
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .subheadline) private var symbolWidth = 22
    var showInformation: () -> Void

    var body: some View {
        DiaryCard(rotation: .zero) {
            VStack(alignment: .leading, spacing: 16) {
                Text("plusBenefitsTitle")
                    .font(.system(.title2, design: .rounded).bold())
                    .foregroundStyle(palette.ink)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier("plusBenefitsTitle")

                VStack(alignment: .leading, spacing: 12) {
                    benefit("plusThemeBenefit", symbol: "paintpalette")
                    benefit("plusTagBenefit", symbol: "tag.fill")
                    benefit("plusRecapBenefit", symbol: "text.book.closed")
                }

                if dynamicTypeSize.isAccessibilitySize {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(premiumThemes) { theme in
                            Label(theme.title, systemImage: theme.symbol)
                                .font(.subheadline)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(theme.palette.ink)
                                .background(theme.palette.background, in: .rect(cornerRadius: 12))
                        }
                    }
                } else {
                    HStack(alignment: .top, spacing: 10) {
                        ForEach(premiumThemes) { theme in
                            PlusThemeSwatch(theme: theme)
                        }
                    }
                }

                HStack(spacing: 12) {
                    Text("plusSameFeatures")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button(action: showInformation) {
                        Label("plusInformationButton", systemImage: "info.circle")
                            .labelStyle(.iconOnly)
                            .font(.title3)
                            .frame(minWidth: 44, minHeight: 44)
                            .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(palette.action)
                    .accessibilityIdentifier("plusInformationButton")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var premiumThemes: [DiaryTheme] {
        DiaryTheme.allCases.filter { $0.product != nil }
    }

    private func benefit(_ title: LocalizedStringKey, symbol: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: symbol)
                .foregroundStyle(palette.action)
                .frame(width: symbolWidth)
                .accessibilityHidden(true)
            Text(title).foregroundStyle(palette.ink)
        }
        .font(.subheadline)
    }
}

private struct PlusThemeSwatch: View {
    var theme: DiaryTheme

    var body: some View {
        VStack(spacing: 6) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: theme.symbol)
                    .foregroundStyle(theme.palette.action)
                Rectangle().fill(theme.palette.lavenderLine).frame(height: 1)
                Rectangle().fill(theme.palette.lavenderLine).frame(height: 1)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.palette.background, in: .rect(cornerRadius: 12))
            Text(theme.title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(theme.title) preview"))
    }
}
