//
//  MoodStickerRow.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import SwiftUI

struct MoodStickerRow: View {
    var viewModel: PageViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Mood for this page")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(PastelTheme.ink)
            HStack(spacing: 12) {
                ForEach(Mood.allCases) { mood in
                    Button {
                        select(mood)
                    } label: {
                        MoodLottieIcon(mood: mood)
                            .font(.system(size: mood == viewModel.selectedMood ? 34 : 30))
                            .frame(width: mood == viewModel.selectedMood ? 60 : 52, height: mood == viewModel.selectedMood ? 60 : 52)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(mood.tint.opacity(mood == viewModel.selectedMood ? 0.36 : 0.12))
                            )
                            .rotationEffect(.degrees(mood == viewModel.selectedMood ? -6 : 0))
                            .shadow(color: mood.tint.opacity(mood == viewModel.selectedMood ? 0.22 : 0), radius: 8, y: 4)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Set page mood to \(mood.title)")
                }
            }
        }
    }

    private func select(_ mood: Mood) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
            viewModel.selectedMood = mood
        }
    }
}

#Preview {
    MoodStickerRow(viewModel: PageViewModel())
}
