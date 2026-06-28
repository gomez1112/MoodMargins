//
//  FlowLayout.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/21/26.
//

import SwiftUI

/// A wrapping layout that arranges child views from left to right and starts a new row when needed.
///
/// `FlowLayout` is useful for tag lists, chips, mood activities, or any collection of variably sized
/// controls that should wrap within the available horizontal space.
///
/// Example:
/// ```swift
/// FlowLayout(spacing: 8) {
///     ForEach(tags, id: \.self) { tag in
///         Text(tag)
///     }
/// }
/// ```
struct FlowLayout: Layout {
    /// The horizontal and vertical distance between adjacent subviews and wrapped rows.
    var spacing: CGFloat = 8

    /// Calculates the size required to display all subviews within the proposed width.
    ///
    /// The layout measures each subview at its ideal size, accumulates items into rows, and wraps to
    /// a new row when adding the next subview would exceed the proposed width.
    ///
    /// - Parameters:
    ///   - proposal: The size proposed by the parent layout. When no width is proposed, the layout
    ///     treats the available width as unbounded.
    ///   - subviews: The child views to measure and arrange.
    ///   - cache: Layout cache storage. This layout does not currently store cached values.
    /// - Returns: The smallest size that contains all rows of subviews using the configured spacing.
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var rowWidth: CGFloat = 0, rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0, totalWidth: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth + size.width > maxWidth, rowWidth > 0 {
                totalHeight += rowHeight + spacing
                totalWidth = max(totalWidth, rowWidth - spacing)
                rowWidth = 0; rowHeight = 0
            }
            rowWidth += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        totalHeight += rowHeight
        totalWidth = max(totalWidth, rowWidth - spacing)
        return CGSize(width: min(totalWidth, maxWidth), height: totalHeight)
    }

    /// Positions each subview within the supplied bounds using the same wrapping behavior as measurement.
    ///
    /// - Parameters:
    ///   - bounds: The rectangle in which the subviews should be placed.
    ///   - proposal: The size proposed by the parent layout.
    ///   - subviews: The child views to place.
    ///   - cache: Layout cache storage. This layout does not currently store cached values.
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX; y += rowHeight + spacing; rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
