//
//  MoodLottieIcon.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/21/26.
//

import DotLottie
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
        .loopMode(reduceMotion ? .playOnce : .loop)
        .playbackMode(reduceMotion ? .paused : .playing)
        .frame(width: size, height: size)
        .allowsHitTesting(false)
    }
}

#Preview {
    MoodLottieIcon(mood: Mood.angry)
}
