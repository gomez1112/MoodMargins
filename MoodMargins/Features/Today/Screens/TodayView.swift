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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @Query(sort: \MoodEntry.date, order: .reverse) private var entries: [MoodEntry]

    @State private var viewModel = TodayViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

        GeometryReader { geometry in
            let usesColumns = geometry.size.width >= 800 && !dynamicTypeSize.isAccessibilitySize
            ScrollView {
                AdaptiveContentWidth(maximumWidth: usesColumns ? 1040 : 680) {
                    VStack(alignment: .leading, spacing: 18) {
                        Header(streak: MoodInsights.currentStreak(entries))
                        if usesColumns {
                            HStack(alignment: .top, spacing: 24) {
                                VStack(alignment: .leading, spacing: 18) {
                                    QuickMoodCard(viewModel: viewModel)
                                    TodayCard(viewModel: viewModel, lines: 10)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                VStack(alignment: .leading, spacing: 24) {
                                    tagSuggestions
                                    if !entries.isEmpty {
                                        RecentPages(entries: entries, isSidebar: true)
                                    }
                                }
                                .frame(width: 300, alignment: .leading)
                            }
                        } else {
                            QuickMoodCard(viewModel: viewModel)
                            TodayCard(viewModel: viewModel)
                            tagSuggestions
                            if !entries.isEmpty { RecentPages(entries: entries) }
                        }
                    }
                    .padding(usesColumns ? 24 : 16)
                }
            }
#if os(iOS) || os(macOS)
            .scrollDismissesKeyboard(.interactively)
#endif
            .frame(maxWidth: .infinity)
        }
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
            viewModel.saveIfChanged(entries: entries, modelContext: modelContext)
            if scenePhase == .active { viewModel.loadTodayIfNeeded(from: entries) }
        }
        .onDisappear { viewModel.saveIfChanged(entries: entries, modelContext: modelContext) }
        .task(id: viewModel.autosaveDraft) { await viewModel.autosave(entries: entries, modelContext: modelContext) }
        .onChange(of: viewModel.note) {
            viewModel.markPageUnsavedIfNoteChanged()
        }
        .task(id: "\(purchases.entitlements.hasPlus):\(viewModel.tagRefreshID(using: modelPreferences.choice))") {
            await viewModel.generateTagSuggestions(using: modelPreferences.choice, hasPlus: purchases.entitlements.hasPlus)
        }
        .alert("Couldn't save your page", isPresented: $viewModel.isShowingSaveError) {
            Button("Try again") { viewModel.saveIfChanged(entries: entries, modelContext: modelContext) }
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.saveErrorMessage ?? "")
        }
    }

    private var tagSuggestions: some View {
        Group {
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
    }

    private var todaySnapshot: DiaryEntrySnapshot? {
        entries.first { Calendar.current.isDateInToday($0.date) }.map(DiaryEntrySnapshot.init)
    }
}
