import SwiftUI

struct WatchCheckInView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab = WatchTab.today
    var journal: WatchJournalStore

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Today", systemImage: "sun.max", value: WatchTab.today) {
                NavigationStack {
                    WatchTodayView(journal: journal, isActive: selectedTab == .today)
                }
            }
            Tab("Recent pages", systemImage: "text.book.closed", value: WatchTab.pages) {
                NavigationStack {
                    WatchRecentPagesView(entries: journal.entries)
                }
            }
        }
        .tabViewStyle(.verticalPage)
        .task(id: journal.draft) { await journal.autosave() }
        .onDisappear { journal.saveIfChanged() }
        .onChange(of: scenePhase) {
            journal.saveIfChanged()
            if scenePhase == .active && !journal.hasChanges { journal.loadToday() }
        }
    }
}

private enum WatchTab { case today, pages }
