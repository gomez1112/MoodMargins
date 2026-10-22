#if DEBUG
import SwiftUI

/// Development-only controls for capturing the same interface in the shipping languages.
struct MarketingCaptureControls: View {
    @Environment(MarketingCaptureState.self) private var capture

    var body: some View {
        @Bindable var capture = capture
        Section {
            Toggle("Screenshot preview", isOn: Binding(get: { capture.isEnabled }, set: capture.setEnabled))
            if capture.isEnabled {
                Picker("Preview language", selection: $capture.language) {
                    Text("English").tag("en")
                    Text("Español").tag("es")
                    Text("العربية").tag("ar")
                }
                Toggle("Dark preview", isOn: $capture.usesDarkAppearance)
                Text("Relaunch the preview after changing its language.")
                    .font(.footnote)
            }
            if let message = capture.errorMessage { Text(message).foregroundStyle(.secondary) }
        } header: {
            Text("Development")
        } footer: {
            Text("Uses fictional entries in a separate preview store. Your journal stays in its own store. This option is excluded from App Store builds.")
        }
    }
}
#endif
