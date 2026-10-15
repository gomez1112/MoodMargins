import SwiftUI

/// Device builds open Apple's review page. Simulators have no App Store to handle it.
struct AppReviewLink: View {
#if targetEnvironment(simulator)
    @State private var isShowingDeviceRequirement = false
#endif

    var body: some View {
#if targetEnvironment(simulator)
        Button(.rateThisApp) { isShowingDeviceRequirement = true }
            .accessibilityIdentifier("rate-this-app")
            .alert(.reviewRequiresDeviceTitle, isPresented: $isShowingDeviceRequirement) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(.reviewSimulatorMessage)
            }
#else
        Link(.rateThisApp, destination: StoreLegal.reviewURL)
            .accessibilityIdentifier("rate-this-app")
#endif
    }
}
