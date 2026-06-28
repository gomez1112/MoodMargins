//
//  CalendarStickerButton.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import SwiftUI

struct CalendarStickerButton: View {
    let entry: MoodEntry
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(entry.date, format: .dateTime.month(.abbreviated))
                    .font(.system(size: 9, design: .rounded).weight(.bold))
                    .foregroundStyle(.secondary)
                Text(entry.date, format: .dateTime.day())
                    .font(.system(.caption, design: .rounded).weight(.bold))
                    .foregroundStyle(PastelTheme.ink)
                MoodLottieIcon(mood: entry.mood, size: isSelected ? 25 : 15)
            }
            .frame(width: isSelected ? 62 : 54, height: isSelected ? 72 : 62)
            .background(entry.mood.tint.opacity(isSelected ? 0.25 : 0.14), in: RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? PastelTheme.ink.opacity(0.55) : .clear, lineWidth: 2)
            }
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.pink.opacity(0.28))
                        .frame(width: 28, height: 9)
                        .rotationEffect(.degrees(8))
                        .offset(x: 3, y: -4)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CalendarStickerButton(entry: .latest, isSelected: true) {}
        .padding()
        .background(PastelTheme.background)
}
