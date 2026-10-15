import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class WatchJournalSession {
    private(set) var container: ModelContainer?
    private(set) var journal: WatchJournalStore?
    private(set) var errorMessage: String?

    init() { open() }

    func open() {
        do {
            let schema = Schema([MoodEntry.self, Activity.self])
#if DEBUG
            let isCapture = ProcessInfo.processInfo.arguments.contains("--marketing-capture")
#else
            let isCapture = false
#endif
            let configuration = ModelConfiguration(
                "WatchJournal", schema: schema, isStoredInMemoryOnly: isCapture,
                cloudKitDatabase: isCapture ? .none : .private("iCloud.com.transfinite.MoodMargins")
            )
            let container = try ModelContainer(for: schema, configurations: [configuration])
            self.container = container
            journal = WatchJournalStore(container: container)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
