//
//  WashiTagButton.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import SwiftUI

struct WashiTagButton: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                action()
            }
        } label: {
            Text("#\(tag)")
                .font(.system(.subheadline, design: .rounded).weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Capsule().fill(PastelTheme.washiColor(tag).opacity(isSelected ? 0.86 : 0.30)))
                .foregroundStyle(isSelected ? .white : PastelTheme.ink)
                .rotationEffect(.degrees(isSelected ? -2 : 0))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    WashiTagButton(tag: "cozy", isSelected: true) {}
        .padding()
        .background(PastelTheme.background)
}
