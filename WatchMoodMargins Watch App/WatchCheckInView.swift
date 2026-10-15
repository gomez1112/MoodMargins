import SwiftUI
import SwiftData

struct WatchCheckInView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab = WatchTab.today
    @State private var pagesPath: [UUID] = []
    @Query(sort: \MoodEntry.date, order: .reverse) private var savedEntries: [MoodEntry]
    var journal: WatchJournalStore

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Today", systemImage: "sun.max", value: WatchTab.today) {
                NavigationStack {
                    WatchTodayView(journal: journal, isActive: selectedTab == .today)
                }
            }
            Tab("Recent pages", systemImage: "text.book.closed", value: WatchTab.pages) {
                NavigationStack(path: $pagesPath) {
                    WatchRecentPagesView(entries: journal.entries)
                }
            }
        }
        .tabViewStyle(.verticalPage)
        .task(id: journal.draft) { await journal.autosave() }
        .onChange(of: savedEntries.map(WatchJournalEntry.init)) {
            journal.synchronize(from: savedEntries.map(WatchJournalEntry.init))
        }
        .onDisappear { journal.saveIfChanged() }
        .onChange(of: scenePhase) {
            journal.saveIfChanged()
            if scenePhase == .active && !journal.hasChanges { journal.loadToday() }
        }
#if DEBUG
        .task {
            if ProcessInfo.processInfo.arguments.contains("--marketing-capture"),
               ProcessInfo.processInfo.arguments.contains("--marketing-pages") {
                selectedTab = .pages
            }
            if ProcessInfo.processInfo.arguments.contains("--marketing-capture"),
               ProcessInfo.processInfo.arguments.contains("--marketing-detail"),
               let entry = journal.entries.first {
                selectedTab = .pages
                pagesPath = [entry.id]
            }
        }
#endif
    }
}

private enum WatchTab { case today, pages }
