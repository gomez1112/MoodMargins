//
//  MoodInsightsTests.swift
//  MoodMarginsTests
//
//  Created by Gerard Gomez on 6/28/26.
//

import Testing
@testable import MoodMargins

@Suite("Mood insight calculations", .serialized)
@MainActor
struct MoodInsightsTests {
    struct AverageMoodScenario: Sendable, CustomTestStringConvertible {
        let name: String
        let moods: [Mood]
        let expectedAverage: Double

        var testDescription: String { name }
    }

    struct DailyAverageScenario: Sendable, CustomTestStringConvertible {
        let name: String
        let entries: [MoodEntryBlueprint]
        let days: Int
        let expectedValues: [Double]

        var testDescription: String { name }
    }

    struct MoodEntryBlueprint: Sendable {
        let daysAgo: Int
        let mood: Mood
    }

    @Test(
        "Average mood handles empty, single, and mixed entries",
        arguments: [
            AverageMoodScenario(name: "empty entries", moods: [], expectedAverage: 0),
            AverageMoodScenario(name: "single lowest mood", moods: [.angry], expectedAverage: 1),
            AverageMoodScenario(name: "single highest mood", moods: [.laughing], expectedAverage: 5),
            AverageMoodScenario(name: "balanced range", moods: [.angry, .mourn, .laughing], expectedAverage: 3),
            AverageMoodScenario(name: "fractional result", moods: [.sad, .mourn, .laughing, .laughing], expectedAverage: 3.75)
        ]
    )
    func averageMood(_ scenario: AverageMoodScenario) {
        let entries = scenario.moods.map { TestFactory.entry(mood: $0) }

        #expect(MoodInsights.averageMood(entries) == scenario.expectedAverage)
    }

    @Test("Distribution includes every mood in app order")
    func distributionIncludesZeroCountsAndPreservesMoodOrder() {
        let entries = [
            TestFactory.entry(mood: .laughing),
            TestFactory.entry(mood: .laughing),
            TestFactory.entry(mood: .sad)
        ]

        let distribution = MoodInsights.distribution(entries)

        #expect(distribution.map(\.mood) == Mood.allCases)
        #expect(distribution.map(\.count) == [0, 1, 0, 0, 2])
    }

    @Test(
        "Daily averages group by calendar day and omit empty days",
        arguments: [
            DailyAverageScenario(
                name: "no entries",
                entries: [],
                days: 7,
                expectedValues: []
            ),
            DailyAverageScenario(
                name: "today only",
                entries: [
                    MoodEntryBlueprint(daysAgo: 0, mood: .angry),
                    MoodEntryBlueprint(daysAgo: 0, mood: .laughing)
                ],
                days: 1,
                expectedValues: [3]
            ),
            DailyAverageScenario(
                name: "oldest to newest with skipped empty days",
                entries: [
                    MoodEntryBlueprint(daysAgo: 2, mood: .sad),
                    MoodEntryBlueprint(daysAgo: 0, mood: .laughing),
                    MoodEntryBlueprint(daysAgo: 2, mood: .mourn)
                ],
                days: 3,
                expectedValues: [2.5, 5]
            ),
            DailyAverageScenario(
                name: "ignores entries outside selected range",
                entries: [
                    MoodEntryBlueprint(daysAgo: 5, mood: .laughing),
                    MoodEntryBlueprint(daysAgo: 1, mood: .wink)
                ],
                days: 2,
                expectedValues: [4]
            )
        ]
    )
    func dailyAverages(_ scenario: DailyAverageScenario) {
        let entries = scenario.entries.map { blueprint in
            TestFactory.entry(date: TestFactory.date(daysAgo: blueprint.daysAgo), mood: blueprint.mood)
        }

        let series = MoodInsights.dailyAverages(entries, days: scenario.days)

        #expect(series.map(\.value) == scenario.expectedValues)
        #expect(series.map(\.id) == Array(scenario.expectedValues.indices))
    }

    @Test("Top activities ignores entries without activities")
    func topActivitiesIgnoresEntriesWithoutActivities() {
        let entries = [
            TestFactory.entry(activities: nil),
            TestFactory.entry(activities: [])
        ]

        let topActivities = MoodInsights.topActivities(entries, limit: 3)

        #expect(topActivities.isEmpty)
    }

    @Test("Top activities ranks repeated activity titles and respects the limit")
    func topActivitiesRanksRepeatedTitles() {
        let entries = [
            TestFactory.entry(activities: [TestFactory.activity(title: "Work"), TestFactory.activity(title: "Rest")]),
            TestFactory.entry(activities: [TestFactory.activity(title: "Work")]),
            TestFactory.entry(activities: [TestFactory.activity(title: "Social"), TestFactory.activity(title: "Work")])
        ]

        let topActivities = MoodInsights.topActivities(entries, limit: 2)

        #expect(topActivities.map { $0.activity.title } == ["Work", "Rest"])
        #expect(topActivities.map(\.count) == [3, 1])
    }

    @Test("Top activities returns no results for a zero limit")
    func topActivitiesHonorsZeroLimit() {
        let entries = [
            TestFactory.entry(activities: [TestFactory.activity(title: "Work")]),
            TestFactory.entry(activities: [TestFactory.activity(title: "Rest")])
        ]

        let topActivities = MoodInsights.topActivities(entries, limit: 0)

        #expect(topActivities.isEmpty)
    }
}
