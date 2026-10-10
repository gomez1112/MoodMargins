//
//  PageView.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import SwiftData
import SwiftUI

struct PageView: View {
    @Environment(\.diaryPalette) private var palette
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query(sort: \MoodEntry.date, order: .reverse) private var entries: [MoodEntry]

    @State private var viewModel = PageViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

        GeometryReader { geometry in
            // Use the window's width so the workspace also adapts to iPad multitasking.
            if geometry.size.width >= 800 && !dynamicTypeSize.isAccessibilitySize {
                AdaptiveContentWidth(maximumWidth: 1120) {
                    HStack(alignment: .top, spacing: 24) {
                        ScrollView {
                            selectedPage(lines: 10)
                                .padding(.top, 8)
                                .padding(.bottom, 24)
                        }
#if os(iOS) || os(macOS)
                        .scrollDismissesKeyboard(.interactively)
#endif
                        .frame(maxWidth: .infinity)
                        ScrollView {
                            pageBrowser
                                .padding(.top, 8)
                                .padding(.bottom, 24)
                        }
                        .swipeActionsContainer()
#if os(iOS) || os(macOS)
                        .scrollDismissesKeyboard(.interactively)
#endif
                        .frame(width: 340)
                        .accessibilityIdentifier("page-browser")
                    }
                    .padding(.horizontal, 24)
                }
            } else {
                ScrollView {
                    AdaptiveContentWidth(maximumWidth: 680) {
                        VStack(alignment: .leading, spacing: 24) {
                            selectedPage(lines: 6)
                            pageBrowser
                        }
                        .padding(22)
                    }
                }
                .swipeActionsContainer()
#if os(iOS) || os(macOS)
                .scrollDismissesKeyboard(.interactively)
#endif
            }
        }
        .safeAreaPadding(.bottom, 16)
        .background(palette.background.ignoresSafeArea())
        .navigationTitle("Pages")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search your pages")
#else
        .searchable(text: $viewModel.searchText, placement: .automatic, prompt: "Search your pages")
#endif
        .onAppear { viewModel.synchronize(from: entries) }
        .onChange(of: selectedSnapshot) { viewModel.synchronize(from: entries) }
        .onChange(of: scenePhase) {
            viewModel.saveIfChanged(entries: entries, modelContext: modelContext)
            if scenePhase == .active { viewModel.synchronize(from: entries) }
        }
        .onDisappear { viewModel.saveIfChanged(entries: entries, modelContext: modelContext) }
        .task(id: viewModel.autosaveDraft) { await viewModel.autosave(entries: entries, modelContext: modelContext) }
        .alert("Couldn't save your page", isPresented: $viewModel.isShowingSaveError) {
            Button("Try again") { viewModel.saveIfChanged(entries: entries, modelContext: modelContext) }
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.saveErrorMessage ?? "")
        }
    }

    private func selectedPage(lines: Int) -> some View {
        @Bindable var viewModel = viewModel
        return VStack(alignment: .leading, spacing: 22) {
            PageDateHeader(date: viewModel.selectedDate, ink: palette.ink)
            MoodStickerRow(viewModel: viewModel)
            LinedNoteCard(
                text: $viewModel.note,
                prompt: "Dear diary…",
                lines: lines,
                paper: palette.paper,
                lineColor: palette.lavenderLine,
                accentColor: viewModel.selectedMood.tint,
                saveStatus: viewModel.saveStatus
            )
            PageTagsView(viewModel: viewModel)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var pageBrowser: some View {
        VStack(alignment: .leading, spacing: 22) {
            PageSectionLabel(title: "Browse past pages", ink: palette.ink)
            if !entries.isEmpty {
                CalendarStickerStrip(viewModel: viewModel, entries: viewModel.calendarEntries(from: entries), selectEntry: selectEntry)
            }
            PageMoodFilter(viewModel: viewModel)
            PastPagesGrid(
                viewModel: viewModel,
                entries: viewModel.filteredEntries(from: entries),
                daysWithMultipleEntries: viewModel.daysWithMultipleEntries(in: entries),
                selectEntry: selectEntry
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func selectEntry(_ entry: MoodEntry) {
        viewModel.selectEntry(entry, entries: entries, modelContext: modelContext)
    }

    private var selectedSnapshot: DiaryEntrySnapshot? {
        let entry = viewModel.selectedEntryID.flatMap { id in entries.first { $0.id == id } }
            ?? entries.first { Calendar.current.isDate($0.date, inSameDayAs: viewModel.selectedDate) }
        return entry.map(DiaryEntrySnapshot.init)
    }
}
