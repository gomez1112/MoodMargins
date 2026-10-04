//
//  TodayView.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/26/26.
//

import SwiftData
import SwiftUI

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \MoodEntry.date, order: .reverse) private var entries: [MoodEntry]

    @State private var viewModel = TodayViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            AdaptiveContentWidth(maximumWidth: 1040) {
                VStack(alignment: .leading, spacing: 18) {
                    Header()
                    QuickMoodCard(selectedMood: $viewModel.selectedMood, pageSaved: $viewModel.pageSaved)

                    ResponsiveTwoColumn(leadingMinWidth: 320, leadingMaxWidth: 560, trailingMinWidth: 320, trailingMaxWidth: 420) {
                        VStack(alignment: .leading, spacing: 18) {
                            TodayCard(viewModel: viewModel) {
                                viewModel.saveTodayPage(entries: entries, modelContext: modelContext)
                            }
                            PromptCard(
                                generatedTags: viewModel.generatedTagSuggestions,
                                isGeneratingTags: viewModel.isGeneratingTagSuggestions,
                                selectGeneratedTag: viewModel.selectGeneratedTag
                            )
                        }
                    } trailing: {
                        RecentPages(entries: entries)
                    }
                }
                .padding()
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaPadding(.bottom, 88)
        .background(PastelTheme.background.ignoresSafeArea())
        .navigationTitle("")
#if !os(macOS)
        .toolbar(.hidden, for: .navigationBar)
#endif
        .onAppear {
            viewModel.loadTodayIfNeeded(from: entries)
        }
        .onDisappear {
            viewModel.cancelTagSuggestions()
        }
        .onChange(of: viewModel.note) {
            viewModel.markPageUnsavedIfNoteChanged()
            viewModel.scheduleTagSuggestions()
        }
    }
}

#Preview {
    NavigationStack {
        TodayView()
    }
}
