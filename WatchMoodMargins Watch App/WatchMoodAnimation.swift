import SwiftUI

/// Lightweight playback of the same Lottie artwork used by the phone app.
struct WatchMoodAnimation: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced
    @Environment(\.scenePhase) private var scenePhase
    @State private var isVisible = false
    var mood: Mood
    var size: CGFloat
    var animates = true

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 15, paused: isPaused)) { context in
            let duration = WatchMoodAnimationFrames.duration(for: mood)
            let count = WatchMoodAnimationFrames.count(for: mood)
            let elapsed = context.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: duration)
            let index = isPaused || context.cadence > .live ? 0 : min(count - 1, Int(elapsed / duration * Double(count)))
            Image("watchMood-\(mood.lottieFileName)-\(index)")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
        .onAppear { isVisible = true }
        .onDisappear { isVisible = false }
    }

    private var isPaused: Bool {
        !animates || !isVisible || reduceMotion || isLuminanceReduced || scenePhase != .active
    }
}
