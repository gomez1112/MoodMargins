//
//  AdaptiveContentWidth.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/21/26.
//

import SwiftUI

/// A layout container that keeps content readable by capping its width on regular-width displays.
///
/// `AdaptiveContentWidth` lets its content fill the available horizontal space on compact layouts,
/// such as iPhone portrait, while centering and constraining that content on regular layouts,
/// such as iPad, Mac, or wide split-view presentations.
///
/// Use this wrapper around page-level content that should remain comfortably readable across
/// multiple Apple platforms:
///
/// ```swift
/// AdaptiveContentWidth(maximumWidth: 960) {
///     TodayView()
/// }
/// ```
struct AdaptiveContentWidth<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    /// The largest width the content can occupy when the horizontal size class is regular.
    var maximumWidth: CGFloat

    /// The view content displayed inside the adaptive width container.
    @ContentBuilder var content: () -> Content

    /// Creates an adaptive content-width container.
    ///
    /// - Parameters:
    ///   - maximumWidth: The maximum centered width to use on regular-width layouts.
    ///     Compact-width layouts always use the full available width. The default is `1120`.
    ///   - content: A view builder that creates the content displayed in the container.
    init(maximumWidth: CGFloat = 1120, @ViewBuilder content: @escaping () -> Content) {
        self.maximumWidth = maximumWidth
        self.content = content
    }

    /// The content constrained to a maximum width on regular horizontal size classes.
    var body: some View {
        content()
            .containerRelativeFrame(.horizontal, alignment: .center) { length, _ in
                horizontalSizeClass == .regular ? min(length, maximumWidth) : length
            }
    }
}

#Preview {
    AdaptiveContentWidth {
        VStack(alignment: .leading, spacing: 16) {
            Text("Adaptive Content Width")
                .font(.title.bold())
            Text("This content expands on compact widths and stays centered with a maximum width on regular widths.")
                .foregroundStyle(.secondary)
            RoundedRectangle(cornerRadius: 12)
                .fill(.blue.gradient)
                .frame(height: 160)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding()
    }
}

