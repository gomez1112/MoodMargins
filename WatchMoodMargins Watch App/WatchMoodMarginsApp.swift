import SwiftUI

@main
struct WatchMoodMarginsApp: App {
    @State private var journal = WatchJournalStore()

    var body: some Scene {
        WindowGroup {
            WatchCheckInView(journal: journal)
        }
    }
}
