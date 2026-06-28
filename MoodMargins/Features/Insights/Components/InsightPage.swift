//
//  InsightPage.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/27/26.
//

import SwiftUI

/// A reusable paper-style container for presenting an insights section.
///
/// `InsightPage` renders a titled header with an SF Symbol, a lightly decorated
/// page background, and caller-provided insight content.
///
/// Example:
/// ```swift
/// InsightPage(title: "Trends", symbol: "chart.line.uptrend.xyaxis", rotation: -1) {
///     TrendCard(insights: insights)
/// }
/// ```
struct InsightPage<Content: View>: View {
    /// The title displayed in the page header.
    let title: String

    /// The SF Symbol name shown next to the title.
    let symbol: String

    /// The number of degrees used to rotate the full page for a handmade layout effect.
    let rotation: Double

    /// The custom insight content displayed below the header.
    @ContentBuilder var content: () -> Content

    /// The composed page view.
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label(title, systemImage: symbol)
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(PastelTheme.ink)
                Spacer()
            }

            content()
        }
        .padding(18)
        .background(PastelTheme.paper, in: RoundedRectangle(cornerRadius: 18))
        .overlay(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 5)
                .fill(.purple.opacity(0.18))
                .frame(width: 66, height: 18)
                .rotationEffect(.degrees(-5))
                .offset(x: -24, y: -9)
        }
        .rotationEffect(.degrees(rotation))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }
}

#Preview {
    VStack {
        Text("HI")
        Text("HI")
        Text("HI")
    }
}
