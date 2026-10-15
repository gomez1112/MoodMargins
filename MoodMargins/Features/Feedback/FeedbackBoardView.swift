import KickstartSignal
import SwiftUI

/// Presented inside the existing sheet host's NavigationStack, which Signal owns for its routes.
struct FeedbackBoardView: View {
    @Environment(\.dismiss) private var dismiss
#if DEBUG
    @Environment(MarketingCaptureState.self) private var marketingCapture
#endif

    var body: some View {
        board
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark") { dismiss() }
                        .labelStyle(.iconOnly)
                        .accessibilityIdentifier("close-feedback")
                }
            }
    }

    @ViewBuilder
    private var board: some View {
#if DEBUG || targetEnvironment(simulator)
        if usesDemoBoard {
            SignalBoardView.demo()
                .safeAreaInset(edge: .bottom) {
                    Text("feedbackDemoNotice")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(.bar)
                        .accessibilityIdentifier("feedback-demo-notice")
                }
        } else {
            liveBoard
        }
#else
        liveBoard
#endif
    }

#if DEBUG || targetEnvironment(simulator)
    private var usesDemoBoard: Bool {
#if DEBUG
        // Live development testing is an explicit opt-in and still requires the owner's
        // Allow Xcode testing setting. Screenshot captures always remain offline.
        marketingCapture.isEnabled || !ProcessInfo.processInfo.arguments.contains("--signal-live-testing")
#else
        // Simulator builds have no production App Store install to verify.
        true
#endif
    }
#endif

    private var liveBoard: some View {
        SignalBoardView(apiKey: "ks_live_-uYuqmZRUIP03QeyjQ45qZMzb49J9Gc2phVPlJQFHzk")
    }
}
