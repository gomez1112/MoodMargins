//
//  TodayView.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/26/26.
//

import SwiftData
import SwiftUI

struct TodayView: View {
    @Environment(\.diaryPalette) private var palette
    @Environment(FoundationModelPreferences.self) private var modelPreferences
    @Environment(PurchaseStore.self) private var purchases
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    @Query(sort: \MoodEntry.date, order: .reverse) private var entries: [MoodEntry]

    @State private var viewModel = TodayViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            AdaptiveContentWidth(maximumWidth: 1040) {
                VStack(alignment: .leading, spacing: 18) {
                    Header(streak: MoodInsights.currentStreak(entries))
                    QuickMoodCard(selectedMood: $viewModel.selectedMood, pageSaved: $viewModel.pageSaved)

                    ResponsiveTwoColumn(leadingMinWidth: 320, leadingMaxWidth: 560, trailingMinWidth: 320, trailingMaxWidth: 420) {
                        VStack(alignment: .leading, spacing: 18) {
                            TodayCard(viewModel: viewModel) {
                                viewModel.saveTodayPage(entries: entries, modelContext: modelContext)
                            }
                            if purchases.entitlements.hasPlus {
                                PromptCard(
                                    generatedTags: viewModel.generatedTagSuggestions,
                                    isGeneratingTags: viewModel.isGeneratingTagSuggestions,
                                    errorMessage: viewModel.tagSuggestionError,
                                    retry: viewModel.retryTagSuggestions,
                                    selectGeneratedTag: viewModel.selectGeneratedTag
                                )
                            } else {
                                PlusFeatureCard(title: String(localized: "AI tags"), message: String(localized: "Plus suggests tags from your note as you write."))
                            }
                        }
                    } trailing: {
                        RecentPages(entries: entries)
                    }
                }
                .padding()
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaPadding(.bottom, 16)
        .background(palette.background.ignoresSafeArea())
        .navigationTitle("")
#if !os(macOS)
        .toolbar(.hidden, for: .navigationBar)
#endif
        .onAppear {
            viewModel.loadTodayIfNeeded(from: entries)
        }
        .onChange(of: todaySnapshot) {
            viewModel.loadTodayIfNeeded(from: entries)
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active { viewModel.loadTodayIfNeeded(from: entries) }
        }
        .onChange(of: viewModel.note) {
            viewModel.markPageUnsavedIfNoteChanged()
        }
        .task(id: "\(purchases.entitlements.hasPlus):\(viewModel.tagRefreshID(using: modelPreferences.choice))") {
            await viewModel.generateTagSuggestions(using: modelPreferences.choice, hasPlus: purchases.entitlements.hasPlus)
        }
        .alert("Couldn't save your page", isPresented: $viewModel.isShowingSaveError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.saveErrorMessage ?? "")
        }
    }

    private var todaySnapshot: DiaryEntrySnapshot? {
        entries.first { Calendar.current.isDateInToday($0.date) }.map(DiaryEntrySnapshot.init)
    }
}
