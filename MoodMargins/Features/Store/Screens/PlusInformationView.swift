import SwiftUI

struct PlusInformationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.diaryPalette) private var palette

    var body: some View {
        NavigationStack {
            Form {
                Section("plusAIInformationTitle") {
                    Text("plusAIProcessingDetails")
                    Text("plusAIReadinessDetails")
                        .foregroundStyle(.secondary)
                }
                Section("plusThemeInformationTitle") {
                    Text("plusThemeOwnershipDetails")
                }
                Section {
                    Link("Privacy policy", destination: StoreLegal.privacyURL)
                }
            }
            .scrollContentBackground(.hidden)
            .background(palette.background.ignoresSafeArea())
            .navigationTitle("plusInformationTitle")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close", systemImage: "xmark") { dismiss() }
                        .labelStyle(.iconOnly)
                }
            }
        }
        .tint(palette.action)
    }
}
