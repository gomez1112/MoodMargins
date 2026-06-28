//
//  PageMoodFilterButton.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import SwiftUI

struct PageMoodFilterButton: View {
    let title: String
    let mood: Mood?
    let selectedMood: Mood?
    let action: () -> Void

    private var isSelected: Bool {
        selectedMood == mood
    }

    private var fill: Color {
        if let mood {
            isSelected ? mood.tint.opacity(0.72) : mood.tint.opacity(0.16)
        } else {
            isSelected ? PastelTheme.ink.opacity(0.70) : .white.opacity(0.55)
        }
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Capsule().fill(fill))
                .foregroundStyle(isSelected ? .white : PastelTheme.ink)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PageMoodFilterButton(title: "Laughing", mood: .laughing, selectedMood: .laughing) {}
        .padding()
        .background(PastelTheme.background)
}
