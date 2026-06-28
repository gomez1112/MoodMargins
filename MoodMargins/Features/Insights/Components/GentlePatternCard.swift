//
//  GentlePatternCard.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/27/26.
//

import SwiftUI

struct GentlePatternCard: View {
    var body: some View {
        InsightPage(title: String(localized: "Soft pattern"), symbol: "leaf.fill", rotation: 0.8) {
            Text("Pages tagged #outdoors often appear with Good or Great moods.")
                .font(.system(.body, design: .serif))
                .foregroundStyle(.primary.opacity(0.82))
        }
    }
}

#Preview {
    GentlePatternCard()
}
