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
    @Environment(NavigationContext.self) private var navigationContext
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @Query(sort: \MoodEntry.date, order: .reverse) private var entries: [MoodEntry]

    @State private var viewModel = TodayViewModel()
    @State private var isNoteFocused = false

    var body: some View {
        @Bindable var viewModel = viewModel

        JournalWorkspace {
            VStack(alignment: .leading, spacing: 18) {
                Header(streak: MoodInsights.currentStreak(entries))
                QuickMoodCard(viewModel: viewModel)
                TodayCard(viewModel: viewModel, lines: 6, focusChanged: { isNoteFocused = $0 })
                tagSuggestions
                Button("Browse past pages", systemImage: "book.pages.fill") {
                    navigationContext.browsePages()
                }
                .buttonStyle(.bordered)
            }
        } secondary: {
            RecentPages(entries: entries, isSidebar: true)
        }
        .safeAreaPadding(.bottom, 16)
        .background { DiaryWindowBackground() }
        .navigationTitle("")
#if !os(macOS)
        .toolbar(.hidden, for: .navigationBar)
#endif
        .modifier(JournalFoldAutosaveModifier {
            viewModel.saveIfChanged(entries: entries, modelContext: modelContext)
        })
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
        .modifier(JournalReviewRequestModifier(
            successfulSaveDate: viewModel.lastSuccessfulSaveDate,
            isEditing: isNoteFocused,
            hasPendingChanges: viewModel.hasPendingChanges,
            hasError: viewModel.saveErrorMessage != nil || viewModel.tagSuggestionError != nil,
            isBusy: viewModel.isGeneratingTagSuggestions
        ))
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
