//
//  TagButton.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/21/26.
//

import SwiftUI

struct PastelTagButton: View {
    let tag: String
    @Binding var selectedTags: Set<String>
    @Binding var pageSaved: Bool
    
    private var isSelected: Bool {
        selectedTags.contains(tag)
    }
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                pageSaved = false
                if isSelected {
                    selectedTags.remove(tag)
                } else {
                    selectedTags.insert(tag)
                }
            }
        } label: {
            Text("#\(tag)")
                .font(.system(.subheadline, design: .rounded).weight(.medium))
                .padding()
                .background(Capsule().fill(PastelTheme.washiColor(tag).opacity(isSelected ? 0.88 : 0.10)))
                .overlay {
                    Capsule()
                        .stroke(PastelTheme.washiColor(tag).opacity(isSelected ? 0 : 0.45), lineWidth: 1)
                }
                .foregroundStyle(isSelected ? .white : PastelTheme.ink.opacity(0.78))
                .rotationEffect(.degrees(isSelected ? -2 : 0))
                .shadow(color: PastelTheme.washiColor(tag).opacity(isSelected ? 0.16 : 0), radius: 5, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Toggle \(tag) tag")
    }
}

#Preview {
    PastelTagButton(tag: "Happy", selectedTags: .constant(["Happy", "Sad"]), pageSaved: .constant(.random()))
}
