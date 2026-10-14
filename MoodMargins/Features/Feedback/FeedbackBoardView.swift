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
#if DEBUG
        if marketingCapture.isEnabled {
            // Screenshot previews stay offline and cannot submit to the live board.
            SignalBoardView.demo()
        } else {
            liveBoard
        }
#else
        liveBoard
#endif
    }

    private var liveBoard: some View {
        SignalBoardView(apiKey: "ks_live_-uYuqmZRUIP03QeyjQ45qZMzb49J9Gc2phVPlJQFHzk")
    }
}
