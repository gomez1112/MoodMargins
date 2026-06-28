//
//  PageMoodFilter.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import SwiftUI

struct PageMoodFilter: View {
    var viewModel: PageViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Filter pages")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(PastelTheme.ink)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    PageMoodFilterButton(title: "All", mood: nil, selectedMood: viewModel.moodFilter) {
                        viewModel.moodFilter = nil
                    }

                    ForEach(Mood.allCases) { mood in
                        PageMoodFilterButton(title: mood.title, mood: mood, selectedMood: viewModel.moodFilter) {
                            viewModel.moodFilter = mood
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    PageMoodFilter(viewModel: PageViewModel())
        .padding()
        .background(PastelTheme.background)
}
