import SwiftUI

struct MoodPicker: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Binding var selection: Mood
    var title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(PastelTheme.ink)
            if dynamicTypeSize.isAccessibilitySize {
                Picker(title, selection: $selection) {
                    ForEach(Mood.allCases) { mood in
                        Text(mood.title).tag(mood)
                    }
                }
                .pickerStyle(.menu)
                .buttonStyle(.bordered)
            } else {
                HStack(alignment: .top, spacing: 8) {
                    ForEach(Mood.allCases) { mood in
                        Button {
                            selection = mood
                        } label: {
                            VStack(spacing: 8) {
                                MoodLottieIcon(mood: mood, size: 44)
                                    .padding(4)
                                    .background(mood.tint.opacity(selection == mood ? 0.26 : 0.10), in: .rect(cornerRadius: 16))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(selection == mood ? PastelTheme.ink : .clear, lineWidth: 2)
                                    }
                                    .accessibilityHidden(true)
                                Text(mood.title)
                                    .font(.system(.caption2, design: .rounded).bold())
                                    .foregroundStyle(PastelTheme.ink)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity)
                            .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(mood.title)
                        .accessibilityAddTraits(selection == mood ? [.isSelected] : [])
                    }
                }
            }
        }
    }
}
