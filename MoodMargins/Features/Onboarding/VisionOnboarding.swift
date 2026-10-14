#if os(visionOS)
import OnboardingKit
import SwiftUI

struct VisionOnboarding<Content: View>: View {
    var currentVersion: String
    var pages: [OnboardingPage]
    var copy: OnboardingCopy
    @ViewBuilder var content: () -> Content
    // Preserve completion from the existing onboarding rather than starting over on update.
    @AppStorage(OnboardingManager.storageKey) private var lastSeenVersion = ""
    @State private var isShowingWelcome = false

    var body: some View {
        content()
            .onAppear {
                isShowingWelcome = lastSeenVersion != currentVersion
#if DEBUG
                // A requested preview must work even after a previous test completed onboarding.
                if ProcessInfo.processInfo.arguments.contains("--show-onboarding") {
                    isShowingWelcome = true
                }
#endif
            }
            .sheet(isPresented: $isShowingWelcome, onDismiss: complete) {
                VisionWelcomeView(pages: pages, copy: copy, onComplete: complete)
                    .presentationSizing(.fitted)
            }
    }

    private func complete() {
        lastSeenVersion = currentVersion
        isShowingWelcome = false
    }
}
#endif
