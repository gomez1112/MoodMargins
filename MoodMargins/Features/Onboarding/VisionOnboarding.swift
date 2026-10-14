#if os(visionOS)
import OnboardingKit
import SwiftUI

struct VisionOnboarding<Content: View>: View {
    var currentVersion: String
    @ViewBuilder var content: () -> Content
    // Preserve completion from the existing onboarding rather than starting over on update.
    @AppStorage(OnboardingManager.storageKey) private var lastSeenVersion = ""
    @State private var isShowingWelcome = false

    var body: some View {
        content()
            .onAppear {
                isShowingWelcome = lastSeenVersion != currentVersion
            }
            .sheet(isPresented: $isShowingWelcome, onDismiss: complete) {
                VisionWelcomeView(onComplete: complete)
                    .presentationSizing(.fitted)
            }
    }

    private func complete() {
        lastSeenVersion = currentVersion
        isShowingWelcome = false
    }
}
#endif
