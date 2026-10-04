import SwiftUI

struct InsightHeader: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Binding var selectedRange: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insights")
                .font(.system(.title, design: .rounded).bold())
                .foregroundStyle(PastelTheme.ink)
                .accessibilityAddTraits(.isHeader)
            Text("A soft look back through your pages")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if dynamicTypeSize.isAccessibilitySize {
                rangePicker.pickerStyle(.menu).buttonStyle(.bordered)
            } else {
                rangePicker.pickerStyle(.segmented)
            }
        }
    }

    private var rangePicker: some View {
        Picker("Range", selection: $selectedRange) {
            Text("7 days").tag(7)
            Text("14 days").tag(14)
            Text("30 days").tag(30)
            Text("Year").tag(365)
        }
    }
}
