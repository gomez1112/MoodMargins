//
//  AdaptiveCardGrid.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/21/26.
//

import SwiftUI

/// A reusable SwiftUI grid that lays out identifiable items as adaptive cards.
///
/// `AdaptiveCardGrid` wraps `LazyVGrid` with a single adaptive column definition,
/// allowing the number of columns to change automatically as horizontal space grows
/// or shrinks. Use it when a collection of similarly sized card views should remain
/// readable across compact and wide layouts.
///
/// Example:
/// ```swift
/// AdaptiveCardGrid(items: moods) { mood in
///     MoodCard(mood: mood)
/// }
/// ```
struct AdaptiveCardGrid<Item: Identifiable, Card: View>: View {
    /// The identifiable values rendered by the grid.
    let items: [Item]

    /// The smallest width a card should occupy before the grid reduces the number of columns.
    let minimumCardWidth: CGFloat

    /// The largest width a card should occupy before the grid adds another column when space allows.
    let maximumCardWidth: CGFloat

    /// The horizontal and vertical spacing between cards.
    let spacing: CGFloat

    /// Builds the card view for a given item.
    let card: (Item) -> Card

    /**
     Creates an adaptive card grid.

     - Parameters:
       - items: The identifiable values to display in the grid.
       - minimumCardWidth: The minimum width for each adaptive card column. Defaults to `160`.
       - maximumCardWidth: The maximum width for each adaptive card column. Defaults to `210`.
       - spacing: The horizontal and vertical spacing between cards. Defaults to `24`.
       - card: A view builder that creates the card content for each item.
     */
    init(items: [Item], minimumCardWidth: CGFloat = 160, maximumCardWidth: CGFloat = 210, spacing: CGFloat = 24, @ContentBuilder card: @escaping (Item) -> Card) {
        self.items = items
        self.minimumCardWidth = minimumCardWidth
        self.maximumCardWidth = maximumCardWidth
        self.spacing = spacing
        self.card = card
    }

    /// The adaptive grid layout containing one card for each item.
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: minimumCardWidth, maximum: maximumCardWidth), spacing: spacing, alignment: .top)], alignment: .leading, spacing: spacing) {
            ForEach(items) { item in
                card(item)
            }
        }
    }
}

private struct AdaptiveCardGridPreviewCard: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let color: Color
    let symbol: String

    static let samples = [
        AdaptiveCardGridPreviewCard(title: "Calm", subtitle: "Morning reflection", color: .blue, symbol: "leaf.fill"),
        AdaptiveCardGridPreviewCard(title: "Focused", subtitle: "Deep work", color: .indigo, symbol: "target"),
        AdaptiveCardGridPreviewCard(title: "Energized", subtitle: "Afternoon walk", color: .orange, symbol: "bolt.fill"),
        AdaptiveCardGridPreviewCard(title: "Grateful", subtitle: "Evening notes", color: .green, symbol: "heart.fill")
    ]
}

#Preview {
    ScrollView {
        AdaptiveCardGrid(items: AdaptiveCardGridPreviewCard.samples) { card in
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: card.symbol)
                    .font(.title2)
                    .foregroundStyle(card.color)

                VStack(alignment: .leading, spacing: 4) {
                    Text(card.title)
                        .font(.headline)
                    Text(card.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
            .padding()
            .background(card.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
        }
        .padding()
    }
}
