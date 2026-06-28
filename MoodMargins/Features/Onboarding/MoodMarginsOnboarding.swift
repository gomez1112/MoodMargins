//
//  MoodMarginsOnboarding.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import OnboardingKit
import SwiftUI

struct MoodMarginsOnboarding<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        OnboardingWrapper(
            appName: "MoodMargins",
            currentVersion: MoodMarginsOnboardingContent.currentVersion,
            pages: MoodMarginsOnboardingContent.pages,
            features: MoodMarginsOnboardingContent.features,
            tint: PastelTheme.ink,
            copy: MoodMarginsOnboardingContent.copy
        ) {
            content
        }
    }
}

private enum MoodMarginsOnboardingContent {
    static var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
    }

    static let copy = OnboardingCopy(
        skipButtonTitle: String(localized: "Skip"),
        nextButtonTitle: String(localized: "Next"),
        getStartedButtonTitle: String(localized: "Start journaling"),
        continueButtonTitle: String(localized: "Continue"),
        whatsNewHeaderTitle: String(localized: "Fresh pages in")
    )

    static var pages: [OnboardingPage] {
        [
            OnboardingPage(
                title: String(localized: "A softer place to check in"),
                description: String(localized: "Pick a mood, jot a few lines, and save the small moments that usually slip past."),
                systemImage: "book.pages.fill",
                backgroundColor: PastelTheme.blush,
                iconColor: PastelTheme.ink
            ),
            OnboardingPage(
                title: String(localized: "Build today with gentle tags"),
                description: String(localized: "Use washi-style tags to connect feelings with routines, people, places, and tiny wins."),
                systemImage: "tag.fill",
                backgroundColor: PastelTheme.paper,
                iconColor: Mood.wink.tint
            ),
            OnboardingPage(
                title: String(localized: "See patterns without pressure"),
                description: String(localized: "Browse past pages and weekly insights when you want a calmer view of what has been shaping your days."),
                systemImage: "chart.line.uptrend.xyaxis",
                backgroundColor: PastelTheme.sky,
                iconColor: Mood.laughing.tint
            )
        ]
    }

    static var features: [FeatureItem] {
        [
            FeatureItem(
                title: String(localized: "Daily mood pages"),
                description: String(localized: "Start from Today, choose a mood, add a note, and save the page when it feels ready."),
                systemImage: "face.smiling.fill",
                backgroundColor: PastelTheme.blush.opacity(0.72),
                iconColor: PastelTheme.ink
            ),
            FeatureItem(
                title: String(localized: "Past page browsing"),
                description: String(localized: "Revisit entries by date, mood, and search so older reflections stay easy to find."),
                systemImage: "calendar",
                backgroundColor: PastelTheme.paper.opacity(0.88),
                iconColor: Mood.wink.tint
            ),
            FeatureItem(
                title: String(localized: "Gentle insights"),
                description: String(localized: "Track streaks, mood distribution, and reflection prompts in the same pastel notebook style."),
                systemImage: "sparkles",
                backgroundColor: PastelTheme.sky.opacity(0.78),
                iconColor: Mood.laughing.tint
            )
        ]
    }
}

#Preview {
    MoodMarginsOnboarding {
        ContentView()
    }
}
