import Foundation
import ImageIO
import SwiftUI
import Testing
import UniformTypeIdentifiers
@testable import MoodMargins

/// Generates deterministic layouts for visual review without altering the user's journal.
@Suite("Insights rendering")
@MainActor
struct InsightsRenderingTests {
    @Test("Charts render across compact, wide, dark, and accessibility layouts")
    func renderCharts() throws {
        let calendar = Calendar.current
        let now = Date()
        let ages = [6, 5, 2, 1, 0]
        let moods: [Mood] = [.angry, .sad, .wink, .mourn, .laughing]
        let entries = try zip(ages, moods).map { age, mood in
            TestFactory.entry(date: try #require(calendar.date(byAdding: .day, value: -age, to: calendar.startOfDay(for: now))), mood: mood, note: "QA fixture", tags: ["family"])
        }
        let model = InsightsViewModel()
        let variants: [(String, CGFloat, ColorScheme, DynamicTypeSize)] = [
            ("compact-light", 393, .light, .large),
            ("compact-dark", 393, .dark, .large),
            ("wide-light", 1024, .light, .large),
            ("accessibility", 393, .dark, .accessibility5)
        ]
        let directory = URL.temporaryDirectory.appending(path: "MoodMargins-Insights-QA", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        for (name, width, appearance, textSize) in variants {
            let content = VStack(alignment: .leading, spacing: 22) {
                SummaryStack(summaryItems: model.summaryItems(for: entries))
                TrendCard(selectedRange: 7, series: model.trendSeries(for: entries))
                DistributionCard(distribution: model.distribution(for: entries))
            }
            .padding(22)
            .frame(width: width)
            .background(PastelTheme.background)
            .environment(\.colorScheme, appearance)
            .environment(\.dynamicTypeSize, textSize)
            let renderer = ImageRenderer(content: content)
            renderer.scale = 1
            let cgImage = try #require(renderer.cgImage)
            #expect(cgImage.width == Int(width))
            let url = directory.appending(path: "\(name).png")
            let destination = try #require(CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil))
            CGImageDestinationAddImage(destination, cgImage, nil)
            #expect(CGImageDestinationFinalize(destination))
        }
    }
}
