import OnboardingKit
import StoreKit
import SwiftUI

/// Offers a native review only at a quiet stopping point after a successful Today save.
struct JournalReviewRequestModifier: ViewModifier {
    var successfulSaveDate: Date?
    var isEditing: Bool
    var hasPendingChanges: Bool
    var hasError: Bool
    var isBusy: Bool

    @Environment(\.requestReview) private var requestReview
    @Environment(\.scenePhase) private var scenePhase
    @Environment(NavigationContext.self) private var navigation
#if DEBUG
    @Environment(MarketingCaptureState.self) private var marketingCapture
#endif
    @State private var pendingOpportunity: UUID?
    @State private var isVisible = false
    @State private var encounteredError = false

    private let policy = ReviewRequestPolicy()

    func body(content: Content) -> some View {
        content
            .onAppear {
                isVisible = true
                encounteredError = hasError
            }
            .onDisappear {
                isVisible = false
                pendingOpportunity = nil
            }
            .onChange(of: successfulSaveDate) {
                guard let successfulSaveDate else { return }
#if DEBUG
                guard !marketingCapture.isEnabled else { return }
#endif
                let eligible = policy.recordCheckIn(on: successfulSaveDate)
                if eligible, isContextActive, !hasError, !encounteredError {
                    pendingOpportunity = UUID()
                }
            }
            .onChange(of: isContextActive) {
                // Discard rather than defer across a paywall, tab switch, or backgrounding.
                if !isContextActive { pendingOpportunity = nil }
            }
            .onChange(of: hasError) {
                if hasError {
                    encounteredError = true
                    pendingOpportunity = nil
                }
            }
            .task(id: opportunityID) {
                guard let opportunity = opportunityID else { return }
                do {
                    try await Task.sleep(for: .seconds(2))
                    try Task.checkCancellation()
                } catch {
                    // The only throwing work is a cancellable delay. Skipping a review is harmless.
                    return
                }
                guard opportunityID == opportunity, policy.claimRequest() else { return }
                pendingOpportunity = nil
                requestReview()
            }
    }

    private var opportunityID: UUID? {
        guard isContextActive, !isEditing, !hasPendingChanges, !hasError,
              !encounteredError, !isBusy else { return nil }
        return pendingOpportunity
    }

    private var isContextActive: Bool {
#if DEBUG
        guard !marketingCapture.isEnabled else { return false }
#endif
        guard let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
              UserDefaults.standard.string(forKey: OnboardingManager.storageKey) == version else { return false }
        return isVisible && scenePhase == .active
            && navigation.selectedTab == .today && navigation.todayPath.isEmpty
            && navigation.presentedSheet == nil && navigation.presentedFullScreenCover == nil
    }
}
