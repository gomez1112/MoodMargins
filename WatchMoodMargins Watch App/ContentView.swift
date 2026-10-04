import SwiftUI

struct WatchCheckInView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Bindable var journal: WatchJournalStore

    var body: some View {
        NavigationStack {
            Form {
                Section("Today") {
                    Picker("Mood", selection: $journal.selectedMood) {
                        ForEach(Mood.allCases) { mood in
                            Label(mood.title, systemImage: mood.systemImage).tag(mood)
                        }
                    }
                    TextField("A short note", text: $journal.note)
                    Button(journal.hasChanges ? "Save check-in" : "Saved", systemImage: "checkmark.seal.fill") {
                        journal.save()
                    }
                    .disabled(!journal.hasChanges || journal.errorMessage != nil)
                    if journal.today != nil {
                        Text("Saved on this Watch")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                if let error = journal.errorMessage {
                    Section {
                        Text(error).foregroundStyle(.red)
                    }
                }
                Section("Recent pages") {
                    if journal.entries.isEmpty {
                        Text("Your check-ins will appear here.")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(journal.entries.prefix(7)) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.date, format: .dateTime.month(.abbreviated).day())
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Label(entry.mood.title, systemImage: entry.mood.systemImage)
                            if !entry.note.isEmpty { Text(entry.note).font(.caption) }
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
            }
            .navigationTitle("MoodMargins")
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active && !journal.hasChanges { journal.loadToday() }
        }
    }
}
