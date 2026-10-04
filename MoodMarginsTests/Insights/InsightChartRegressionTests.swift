import Foundation
import Testing
@testable import MoodMargins

@Suite("Insight chart regressions")
@MainActor
struct InsightChartRegressionTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        return calendar
    }

    private func now() throws -> Date {
        try Date("2026-10-04T12:00:00Z", strategy: .iso8601)
    }

    private func date(daysAgo: Int, now: Date) throws -> Date {
        try #require(calendar.date(byAdding: .day, value: -daysAgo, to: calendar.startOfDay(for: now)))
    }

    @Test("Missing calendar days create gaps with stable date identities")
    func calendarGaps() throws {
        let now = try now()
        let dates = try [5, 4, 1, 0].map { try date(daysAgo: $0, now: now) }
        let entries = dates.map { TestFactory.entry(date: $0, mood: .wink, note: "", tags: []) }
        let series = MoodInsights.dailyAverages(entries, days: 7, calendar: calendar, now: now)
        #expect(series.map(\.id) == dates)
        #expect(series.map(\.segmentStart) == [dates[0], dates[0], dates[2], dates[2]])
        #expect(MoodInsights.dailyAverages(entries, days: 0, calendar: calendar, now: now).isEmpty)
    }

    @Test("A range includes its first day and excludes older and future entries")
    func rangeBounds() throws {
        let now = try now()
        let entries = try [7, 6, 0, -1].map {
            TestFactory.entry(date: try date(daysAgo: $0, now: now), mood: .sad, note: "", tags: [])
        }
        let included = MoodInsights.entries(entries, days: 7, calendar: calendar, now: now)
        #expect(included.map(\.id) == [entries[1].id, entries[2].id])
        let snapshot = InsightRecapSnapshotBuilder.snapshot(from: entries, selectedRange: 7, calendar: calendar, now: now)
        #expect(snapshot.entryCount == included.count)
        #expect(snapshot.trend == .steady)
    }

    @Test("Streak counts days rather than entries and allows an unfinished today", arguments: [
        ([0, 0, 1, 2, 4], 3), ([1, 2], 2), ([2], 0), ([], 0), ([-1], 0)
    ])
    func streak(_ scenario: ([Int], Int)) throws {
        let now = try now()
        let entries = try scenario.0.map {
            TestFactory.entry(date: try date(daysAgo: $0, now: now), mood: .wink, note: "", tags: [])
        }
        #expect(MoodInsights.currentStreak(entries, calendar: calendar, now: now) == scenario.1)
    }

    @Test("Every insight uses the selected range without fabricated empty values")
    func consistentRange() throws {
        let recent = TestFactory.entry(date: Date(), mood: .sad, note: "", tags: ["family"], activities: [Activity(title: "Reading", symbol: "book.closed")])
        let oldDate = try #require(Calendar.current.date(byAdding: .day, value: -20, to: Date()))
        let old = TestFactory.entry(date: oldDate, mood: .laughing, note: "", tags: ["old"], activities: [Activity(title: "Work", symbol: "book.closed")])
        let model = InsightsViewModel()
        model.selectedRange = 7
        let entries = [recent, old]
        let summary = Dictionary(uniqueKeysWithValues: model.summaryItems(for: entries).map { ($0.id, $0.value) })
        #expect(summary["entries"] == "1")
        #expect(summary["common"] == Mood.sad.title)
        #expect(summary["topTag"] == "#family")
        #expect(model.distribution(for: entries).reduce(0) { $0 + $1.count } == 1)
        #expect(model.topActivities(for: entries).map { $0.activity.title } == ["Reading"])
        #expect(model.trendSeries(for: entries).count == 1)
        model.selectedRange = 30
        #expect(model.distribution(for: entries).reduce(0) { $0 + $1.count } == 2)
        let empty = Dictionary(uniqueKeysWithValues: model.summaryItems(for: []).map { ($0.id, $0.value) })
        #expect(empty["common"] == "—")
        #expect(empty["topTag"] == "—")
        #expect(empty["average"] == "—")
    }

    @Test("Patterns reflect actual repeated tags and mood scores")
    func factualPatterns() {
        let entries = [
            TestFactory.entry(date: Date(), mood: .sad, note: "", tags: ["family", "family"]),
            TestFactory.entry(date: Date(), mood: .wink, note: "", tags: ["family"])
        ]
        let pattern = MoodInsights.pattern(entries)
        #expect(pattern.contains("#family"))
        #expect(pattern.contains("2 pages"))
        #expect(pattern.contains("mix of moods"))
        #expect(!pattern.contains("out of 5"))
        #expect(!pattern.contains("outdoors"))
        #expect(!MoodInsights.pattern([]).contains("outdoors"))
    }

    @Test("The first chart label sits at the start of every selectable range", arguments: [7, 14, 30, 365])
    func chartLabelsIncludeOrigin(_ days: Int) throws {
        let now = try now()
        let range = MoodInsights.chartDateRange(days: days, calendar: calendar, now: now)
        let ticks = MoodInsights.chartTickDates(days: days, calendar: calendar, now: now)
        #expect(ticks.first == range.lowerBound)
        #expect(ticks.last == range.upperBound)
        #expect(range.lowerBound == (try date(daysAgo: days - 1, now: now)))
        #expect(range.upperBound == calendar.startOfDay(for: now))
    }

    @Test("Overall mood describes days without rounding a balanced 3.5 into a mood")
    func descriptiveOverallMood() throws {
        let now = try now()
        let today = try date(daysAgo: 0, now: now)
        let yesterday = try date(daysAgo: 1, now: now)
        let mixed = [
            TestFactory.entry(date: today, mood: .mourn),
            TestFactory.entry(date: today, mood: .wink)
        ]
        #expect(MoodInsights.overallMoodSummary(mixed) == "A mix of moods")
        let lighter = [
            TestFactory.entry(date: today, mood: .laughing),
            TestFactory.entry(date: yesterday, mood: .wink)
        ]
        #expect(MoodInsights.overallMoodSummary(lighter) == "Mostly lighter days")
        #expect(MoodInsights.overallMoodSummary([lighter[0]]) == Mood.laughing.title)
        #expect(MoodInsights.moodDescription(for: 3.5) == "Between \(Mood.mourn.title) and \(Mood.wink.title)")
    }
}
