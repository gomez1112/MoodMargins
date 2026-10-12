//
//  PageSectionLabel.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import SwiftUI

struct PageSectionLabel: View {
    var title: LocalizedStringKey
    let ink: Color
    var topPadding: CGFloat = 0

    var body: some View {
        Text(title)
            .font(.system(.caption, design: .rounded).weight(.bold))
            .foregroundStyle(ink)
            .textCase(.uppercase)
            .padding(.top, topPadding)
            .accessibilityAddTraits(.isHeader)
    }
}
