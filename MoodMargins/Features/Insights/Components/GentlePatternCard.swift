//
//  GentlePatternCard.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/27/26.
//

import SwiftUI

struct GentlePatternCard: View {
    @Environment(\.diaryPalette) private var palette
    var pattern: String
    var body: some View {
        InsightPage(title: String(localized: "Soft pattern"), symbol: "leaf.fill", rotation: 0.8) {
            Text(pattern)
                .font(.system(.body, design: .serif))
                .foregroundStyle(palette.ink)
        }
    }
}
