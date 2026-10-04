import SwiftData
import SwiftUI

struct PastPagesGrid: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var deleteError: String?
    var viewModel: PageViewModel
    var entries: [MoodEntry]
    var daysWithMultipleEntries: Set<Date>

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Past pages")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(PastelTheme.ink)
                Spacer()
                Text(entries.count, format: .number)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if entries.isEmpty {
                ContentUnavailableView {
                    Label("No matching pages", systemImage: "book.closed")
                } description: {
                    Text("Try another search or mood filter, or save your first page.")
                }
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(entries) { entry in
                        pageButton(entry)
                    }
                }
            }
        }
        .alert("Couldn't delete your page", isPresented: Binding {
            deleteError != nil
        } set: { if !$0 { deleteError = nil } }) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(deleteError ?? "")
        }
    }

    private var columns: [GridItem] {
        dynamicTypeSize.isAccessibilitySize
            ? [GridItem(.flexible())]
            : [GridItem(.adaptive(minimum: 160), spacing: 16)]
    }

    private func pageButton(_ entry: MoodEntry) -> some View {
        Button {
            viewModel.loadEntry(entry)
        } label: {
            MiniDiaryPage(entry: entry, showsTime: daysWithMultipleEntries.contains(Calendar.current.startOfDay(for: entry.date)))
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button("Delete", systemImage: "trash", role: .destructive) { delete(entry) }
        }
        .contextMenu {
            Button("Delete", systemImage: "trash", role: .destructive) { delete(entry) }
        }
        .accessibilityAction(named: "Delete") { delete(entry) }
    }

    private func delete(_ entry: MoodEntry) {
        do {
            modelContext.delete(entry)
            try modelContext.save()
        } catch {
            modelContext.rollback()
            deleteError = error.localizedDescription
        }
    }
}
