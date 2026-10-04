//
//  CalendarStickerStrip.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import SwiftUI

struct CalendarStickerStrip: View {
    @Environment(\.diaryPalette) private var palette
    var viewModel: PageViewModel
    let entries: [MoodEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Calendar stickers")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(palette.ink)
                Spacer()
                Text(viewModel.selectedDate, format: .dateTime.month(.wide).year())
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(entries.prefix(10)) { entry in
                        CalendarStickerButton(
                            entry: entry,
                            isSelected: Calendar.current.isDate(entry.date, inSameDayAs: viewModel.selectedDate)
                        ) {
                            viewModel.loadEntry(entry)
                        }
                    }
                }
                .padding(.vertical, 6)
            }
        }
    }
}
