//
//  QuickMoodCard.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/26/26.
//

import SwiftUI

struct QuickMoodCard: View {
    @Binding var selectedMood: Mood
    @Binding var pageSaved: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Today I feel...")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(PastelTheme.ink)
            HStack {
                ForEach(Mood.allCases) { mood in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
                            selectedMood = mood
                            pageSaved = false
                        }
                    } label: {
                        VStack {
                            MoodLottieIcon(mood: mood, size: mood == selectedMood ? 62 : 52)
                                .background(mood.tint.opacity(mood == selectedMood ? 0.34 : 0.12), in: RoundedRectangle(cornerRadius: 17))
                                .rotationEffect(.degrees(mood == selectedMood ? -6 : 0))
                                .shadow(color: mood.tint.opacity(mood == selectedMood ? 0.24 : 0), radius: 8, y: 4)
                            Text(mood.title)
                                .font(.system(size: 10, design: .rounded).weight(.semibold))
                                .foregroundStyle(PastelTheme.softInk)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Set mood to \(mood.title)")
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedMood: Mood = .angry
    QuickMoodCard(selectedMood: $selectedMood, pageSaved: .constant(true))
}
