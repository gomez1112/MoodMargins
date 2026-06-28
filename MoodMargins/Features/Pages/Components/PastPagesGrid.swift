//
//  PastPagesGrid.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import SwiftData
import SwiftUI

struct PastPagesGrid: View {
    @Environment(\.modelContext) private var modelContext

    var viewModel: PageViewModel
    let entries: [MoodEntry]
    let daysWithMultipleEntries: Set<Date>

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Past pages")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(PastelTheme.ink)
                Spacer()
                Text("\(entries.count)")
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            AdaptiveCardGrid(items: entries, minimumCardWidth: 150, maximumCardWidth: 210, spacing: 24) { entry in
                let showsTime = daysWithMultipleEntries.contains(Calendar.current.startOfDay(for: entry.date))

                Button {
                    viewModel.loadEntry(entry)
                } label: {
                    MiniDiaryPage(entry: entry, showsTime: showsTime)
                }
                .buttonStyle(.plain)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        delete(entry)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }

    private func delete(_ entry: MoodEntry) {
        do {
            modelContext.delete(entry)
            try modelContext.save()
        } catch {
            assertionFailure("Failed to delete diary page: \(error)")
        }
    }
}

#Preview {
    PastPagesGrid(viewModel: PageViewModel(), entries: [MoodEntry.latest], daysWithMultipleEntries: [])
        .padding()
        .background(PastelTheme.background)
}
