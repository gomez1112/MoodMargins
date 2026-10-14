//
//  MoodLottieIcon.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/21/26.
//

import DotLottie
import QuartzCore
import SwiftUI

struct MoodLottieIcon: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let mood: Mood
    let size: CGFloat

    init(mood: Mood, size: CGFloat = 40) {
        self.mood = mood
        self.size = size
    }

    var body: some View {
        DotLottiePlayerView(
            animation: DotLottieAnimation(
                fileName: mood.lottieFileName,
                config: AnimationConfig(autoplay: !reduceMotion, loop: !reduceMotion)
            )
        )
        .configure { view in
            // DotLottie's existing platform renderer owns the Metal layers. Prevent
            // a device's Graphics HUD setting from covering these small mood stickers.
#if os(macOS)
            if let layer = view.layer { disablePerformanceOverlay(in: layer) }
#else
            disablePerformanceOverlay(in: view.layer)
#endif
        }
        .loopMode(reduceMotion ? .playOnce : .loop)
        .playbackMode(reduceMotion ? .paused : .playing)
        .frame(width: size, height: size)
#if os(visionOS)
        // DotLottie's Core Image → Metal path reverses the image rows on visionOS.
        // Correct only the artwork; labels and selection controls remain upright.
        .scaleEffect(x: 1, y: -1)
#endif
        .allowsHitTesting(false)
    }

    private func disablePerformanceOverlay(in layer: CALayer) {
        if let metalLayer = layer as? CAMetalLayer {
            metalLayer.developerHUDProperties = ["mode": "disabled", "logging": "disabled"]
        }
        for sublayer in layer.sublayers ?? [] {
            disablePerformanceOverlay(in: sublayer)
        }
    }
}
