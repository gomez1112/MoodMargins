//
//  MiniDiaryPage.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/21/26.
//

import SwiftUI

struct MiniDiaryPage: View {
    let entry: MoodEntry
    var showsTime = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                MoodLottieIcon(mood: entry.mood, size: 34)
                Spacer()
                VStack(alignment: .trailing) {
                    Text(entry.date, format: .dateTime.day().month())
                    if showsTime {
                        Text(entry.date, format: .dateTime.hour().minute())
                    }
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
            Text(entry.note)
                .font(.system(.caption, design: .serif))
                .foregroundStyle(.primary.opacity(0.8))
                .lineLimit(3)
            Spacer()
            HStack {
                ForEach(entry.tags.prefix(2), id: \.self) { tag in
                    Text("#\(tag)")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .frame(width: 150, height: 150, alignment: .topLeading)
        .background(PastelTheme.paper, in: RoundedRectangle(cornerRadius: 16))
        .rotationEffect(.degrees(Double(entry.mood.rawValue % 2 == 0 ? 2 : -2)))
        .shadow(color: .black.opacity(0.06), radius: 5, y: 3)
    }
}

#Preview {
    MiniDiaryPage(entry: MoodEntry.latest)
}
