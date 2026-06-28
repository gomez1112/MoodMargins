//
//  RecentPages.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/21/26.
//

import SwiftUI

struct RecentPages: View {
    let entries: [MoodEntry]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Recent pages")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(PastelTheme.ink)
                .padding()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(entries) { entry in
                        MiniDiaryPage(entry: entry)
                            .scrollTransition(axis: .horizontal) { content, phase in
                                content
                                    .blur(radius: min(abs(phase.value), 1) * 1.2)
                                    .opacity(1 - (min(abs(phase.value), 1) * 0.22))
                                    .rotation3DEffect(
                                        .degrees(phase.value * -12),
                                        axis: (x: 0, y: 1, z: 0),
                                        perspective: 0.7
                                    )
                                    .rotationEffect(.degrees(phase.value * 1.5))
                                    .offset(
                                        x: phase.value * -10,
                                        y: min(abs(phase.value), 1) * 14
                                    )
                            }
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(.vertical, 10)
            .scrollTargetBehavior(.viewAligned)
        }
    }
}

#Preview {
    RecentPages(entries: MoodEntry.samples)
}
