import SwiftUI
import SwiftData

@main
struct WatchMoodMarginsApp: App {
    @State private var session = WatchJournalSession()

    var body: some Scene {
        WindowGroup {
            Group {
                if let journal = session.journal, let container = session.container {
                    WatchCheckInView(journal: journal)
                        .modelContainer(container)
                } else {
                    ContentUnavailableView {
                        Label(.watchJournalOpenError, systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(session.errorMessage ?? "")
                    } actions: {
                        Button(.watchRetry) { session.open() }
                    }
                }
            }
                .tint(WatchDiaryStyle.action)
                .preferredColorScheme(.dark)
        }
    }
}
