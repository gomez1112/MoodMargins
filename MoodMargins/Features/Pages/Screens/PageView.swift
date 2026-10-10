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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query(sort: \MoodEntry.date, order: .reverse) private var entries: [MoodEntry]

    @State private var viewModel = PageViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            AdaptiveContentWidth(maximumWidth: 1120) {
                VStack(alignment: .leading, spacing: 24) {
                    PageDateHeader(date: viewModel.selectedDate, ink: palette.ink)

                    if horizontalSizeClass == .compact {
                        VStack(alignment: .leading, spacing: 22) {
                            PageSectionLabel(title: "Current selected page", ink: palette.ink)
                            LinedNoteCard(
                                text: $viewModel.note,
                                prompt: "Dear diary…",
                                lines: 6,
                                paper: palette.paper,
                                lineColor: palette.lavenderLine,
                                accentColor: viewModel.selectedMood.tint,
                                saveStatus: viewModel.saveStatus
                            )
                            PageTagsView(viewModel: viewModel)
                            CalendarStickerStrip(viewModel: viewModel, entries: viewModel.calendarEntries(from: entries), selectEntry: selectEntry)
                            MoodStickerRow(viewModel: viewModel)
                        }
                    } else {
                        ResponsiveTwoColumn(
                            leadingMinWidth: 300,
                            leadingMaxWidth: 420,
                            trailingMinWidth: 380,
                            trailingMaxWidth: 640
                        ) {
                            VStack(alignment: .leading, spacing: 22) {
                                CalendarStickerStrip(viewModel: viewModel, entries: viewModel.calendarEntries(from: entries), selectEntry: selectEntry)
                                MoodStickerRow(viewModel: viewModel)
                            }
                        } trailing: {
                            VStack(alignment: .leading, spacing: 22) {
                                PageSectionLabel(title: "Current selected page", ink: palette.ink)
                                LinedNoteCard(
                                    text: $viewModel.note,
                                    prompt: "Dear diary…",
                                    lines: 6,
                                    paper: palette.paper,
                                    lineColor: palette.lavenderLine,
                                    accentColor: viewModel.selectedMood.tint,
                                    saveStatus: viewModel.saveStatus
                                )
                                PageTagsView(viewModel: viewModel)
                            }
                        }
                    }

                    PageSectionLabel(title: "Browse past pages", ink: palette.ink, topPadding: 8)
                    PageMoodFilter(viewModel: viewModel)
                    PastPagesGrid(
                        viewModel: viewModel,
                        entries: viewModel.filteredEntries(from: entries),
                        daysWithMultipleEntries: viewModel.daysWithMultipleEntries(in: entries),
                        selectEntry: selectEntry
                    )
                }
                .padding(22)
            }
        }
        .swipeActionsContainer()
#if os(iOS) || os(macOS)
        .scrollDismissesKeyboard(.interactively)
#endif
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

    private func selectEntry(_ entry: MoodEntry) {
        viewModel.selectEntry(entry, entries: entries, modelContext: modelContext)
    }

    private var selectedSnapshot: DiaryEntrySnapshot? {
        let entry = viewModel.selectedEntryID.flatMap { id in entries.first { $0.id == id } }
            ?? entries.first { Calendar.current.isDate($0.date, inSameDayAs: viewModel.selectedDate) }
        return entry.map(DiaryEntrySnapshot.init)
    }
}
