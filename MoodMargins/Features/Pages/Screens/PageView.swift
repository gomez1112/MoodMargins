//
//  PageView.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import SwiftData
import SwiftUI

struct PageView: View {
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
                    PageDateHeader(date: viewModel.selectedDate, ink: PastelTheme.ink)

                    if horizontalSizeClass == .compact {
                        VStack(alignment: .leading, spacing: 22) {
                            PageSectionLabel(title: "Current selected page", ink: PastelTheme.ink)
                            LinedNoteCard(
                                text: $viewModel.note,
                                prompt: "Dear diary…",
                                lines: 6,
                                paper: PastelTheme.paper,
                                lineColor: PastelTheme.lavenderLine,
                                accentColor: viewModel.selectedMood.tint
                            ) {
                                viewModel.saveCurrentPage(entries: entries, modelContext: modelContext)
                            }
                            CalendarStickerStrip(viewModel: viewModel, entries: viewModel.calendarEntries(from: entries))
                            MoodStickerRow(viewModel: viewModel)
                            WashiTags(viewModel: viewModel)
                        }
                    } else {
                        ResponsiveTwoColumn(
                            leadingMinWidth: 300,
                            leadingMaxWidth: 420,
                            trailingMinWidth: 380,
                            trailingMaxWidth: 640
                        ) {
                            VStack(alignment: .leading, spacing: 22) {
                                CalendarStickerStrip(viewModel: viewModel, entries: viewModel.calendarEntries(from: entries))
                                MoodStickerRow(viewModel: viewModel)
                                WashiTags(viewModel: viewModel)
                            }
                        } trailing: {
                            VStack(alignment: .leading, spacing: 22) {
                                PageSectionLabel(title: "Current selected page", ink: PastelTheme.ink)
                                LinedNoteCard(
                                    text: $viewModel.note,
                                    prompt: "Dear diary…",
                                    lines: 6,
                                    paper: PastelTheme.paper,
                                    lineColor: PastelTheme.lavenderLine,
                                    accentColor: viewModel.selectedMood.tint
                                ) {
                                    viewModel.saveCurrentPage(entries: entries, modelContext: modelContext)
                                }
                            }
                        }
                    }

                    PageSectionLabel(title: "Browse past pages", ink: PastelTheme.ink, topPadding: 8)
                    PageMoodFilter(viewModel: viewModel)
                    PastPagesGrid(
                        viewModel: viewModel,
                        entries: viewModel.filteredEntries(from: entries),
                        daysWithMultipleEntries: viewModel.daysWithMultipleEntries(in: entries)
                    )
                }
                .padding(22)
            }
        }
        .swipeActionsContainer()
        .scrollDismissesKeyboard(.interactively)
        .safeAreaPadding(.bottom, 16)
        .background(PastelTheme.background.ignoresSafeArea())
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
            if scenePhase == .active { viewModel.synchronize(from: entries) }
        }
        .alert("Couldn't save your page", isPresented: $viewModel.isShowingSaveError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.saveErrorMessage ?? "")
        }
    }

    private var selectedSnapshot: DiaryEntrySnapshot? {
        let entry = viewModel.selectedEntryID.flatMap { id in entries.first { $0.id == id } }
            ?? entries.first { Calendar.current.isDate($0.date, inSameDayAs: viewModel.selectedDate) }
        return entry.map(DiaryEntrySnapshot.init)
    }
}
