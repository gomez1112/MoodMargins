//
//  ResponsiveTwoColumn.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/21/26.
//

import SwiftUI

/// A responsive layout that presents leading and trailing content in two columns when space allows.
///
/// `ResponsiveTwoColumn` first attempts to lay out its children horizontally using their configured
/// minimum and maximum widths. If the horizontal arrangement does not fit, it falls back to a
/// vertically stacked layout that preserves the same spacing between sections.
///
/// ```swift
/// ResponsiveTwoColumn {
///     SummaryCard()
/// } trailing: {
///     DetailCard()
/// }
/// ```
struct ResponsiveTwoColumn<Leading: View, Trailing: View>: View {
    /// The distance between columns in the horizontal layout and between views in the vertical fallback.
    let spacign: CGFloat

    /// The minimum width reserved for the leading column before falling back to the vertical layout.
    let leadingMinWidth: CGFloat

    /// The optional maximum width for the leading column.
    let leadingMaxWidth: CGFloat?

    /// The minimum width reserved for the trailing column before falling back to the vertical layout.
    let trailingMinWidth: CGFloat

    /// The optional maximum width for the trailing column.
    let trailingMaxWidth: CGFloat?

    /// A builder that creates the leading column content.
    let leading: () -> Leading

    /// A builder that creates the trailing column content.
    let trailing: () -> Trailing

    /// Creates a responsive two-column layout.
    ///
    /// - Parameters:
    ///   - spacign: The spacing between the leading and trailing content. Defaults to `24`.
    ///   - leadingMinWidth: The minimum width for the leading column. Defaults to `340`.
    ///   - leadingMaxWidth: The optional maximum width for the leading column. Pass `nil` to allow it to expand.
    ///   - trailingMinWidth: The minimum width for the trailing column. Defaults to `520`.
    ///   - trailingMaxWidth: The optional maximum width for the trailing column. Pass `nil` to allow it to expand.
    ///   - leading: A content builder that produces the leading column view.
    ///   - trailing: A content builder that produces the trailing column view.
    init(spacign: CGFloat = 24, leadingMinWidth: CGFloat = 340, leadingMaxWidth: CGFloat? = nil, trailingMinWidth: CGFloat = 520, trailingMaxWidth: CGFloat? = nil, @ContentBuilder leading: @escaping () -> Leading, @ContentBuilder trailing: @escaping () -> Trailing) {
        self.spacign = spacign
        self.leadingMinWidth = leadingMinWidth
        self.leadingMaxWidth = leadingMaxWidth
        self.trailingMinWidth = trailingMinWidth
        self.trailingMaxWidth = trailingMaxWidth
        self.leading = leading
        self.trailing = trailing
    }

    /// The adaptive layout body.
    ///
    /// The horizontal version is evaluated first. When the configured minimum widths cannot fit in
    /// the available horizontal space, SwiftUI uses the vertical fallback instead.
    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: spacign) {
                leading()
                    .frame(minWidth: leadingMinWidth, maxWidth: leadingMaxWidth ?? .infinity, alignment: .topLeading)
                trailing()
                    .frame(minWidth: trailingMinWidth, maxWidth: trailingMaxWidth ?? .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, alignment: .top)
            VStack(alignment: .leading, spacing: spacign) {
                leading()
                trailing()
            }
        }
    }
}

#Preview {
    ResponsiveTwoColumn {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today")
                .font(.headline)
            Text("Calm focus")
                .font(.largeTitle.weight(.semibold))
            Text("A compact leading column for summary content, filters, or controls.")
                .foregroundStyle(.secondary)
        }
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    } trailing: {
        VStack(alignment: .leading, spacing: 16) {
            Text("Mood Notes")
                .font(.title2.weight(.semibold))
            Text("Use the wider trailing column for primary detail content. Resize the preview to see the layout fall back to a vertical stack when horizontal space is constrained.")
                .foregroundStyle(.secondary)
            Divider()
            ForEach(["Morning walk", "Deep work", "Evening reflection"], id: \.self) { item in
                Label(item, systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.primary, .green)
            }
        }
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
    }
    .padding()
}
