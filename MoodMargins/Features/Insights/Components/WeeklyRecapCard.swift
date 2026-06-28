//
//  WeeklyRecapCard.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/27/26.
//

import SwiftUI

struct WeeklyRecapCard: View {
    let selectedRange: Int
    
    var body: some View {
        InsightPage(title: selectedRange == 365 ? String(localized: "Year recap") : String(localized: "\(selectedRange)-day recap"), symbol: "text.book.closed.fill", rotation: -0.8) {
            Text("This period had a mix of steady and tired days. You wrote most about rest, work, and calm moments.")
                .font(.system(.body, design: .serif))
                .lineSpacing(5)
                .foregroundStyle(.primary.opacity(0.82))
        }
    }
}

#Preview {
    WeeklyRecapCard(selectedRange: 14)
}
