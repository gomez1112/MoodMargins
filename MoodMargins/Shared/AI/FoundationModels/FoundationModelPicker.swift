import FoundationModels
import SwiftUI

struct FoundationModelPicker: View {
    @Environment(FoundationModelPreferences.self) private var preferences

    var body: some View {
        @Bindable var preferences = preferences
        VStack(alignment: .leading, spacing: 8) {
            Picker("Generate with", selection: $preferences.choice) {
                ForEach(FoundationModelChoice.allCases) { choice in
                    Text(choice.title).tag(choice)
                }
            }
            .pickerStyle(.menu)
            .buttonStyle(.bordered)
            Text(preferences.choice.explanation)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            if let status = FoundationModelService.status(for: preferences.choice) {
                Text(status)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if preferences.choice == .privateCloudCompute,
               let suggestion = FoundationModelService.cloudModel.quotaUsage.limitIncreaseSuggestion {
                Button("Manage cloud limit", systemImage: "cloud") { suggestion.show() }
                    .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
