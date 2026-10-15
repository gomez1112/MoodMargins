import Foundation
import Testing
@testable import MoodMargins

@Suite("Review request policy")
@MainActor
struct ReviewRequestPolicyTests {
    @Test("Three distinct check-in days are required, regardless of autosave frequency")
    func distinctDays() throws {
        try withPolicy { policy, defaults in
            let first = try day(0)
            for _ in 0..<20 {
                #expect(!policy.recordCheckIn(on: first, now: first))
            }
            #expect(!policy.recordCheckIn(on: try day(1), now: try day(1)))
            #expect(policy.recordCheckIn(on: try day(2), now: try day(2)))
            let relaunched = ReviewRequestPolicy(defaults: defaults, version: "1.0", calendar: calendar)
            #expect(relaunched.isEligible(now: try day(2)))
        }
    }

    @Test("Past and future pages cannot count as today's check-in")
    func onlyTodaysSaves() throws {
        try withPolicy { policy, _ in
            let today = try day(2)
            #expect(!policy.recordCheckIn(on: try day(0), now: today))
            #expect(!policy.recordCheckIn(on: try day(1), now: today))
            #expect(!policy.recordCheckIn(on: try day(3), now: today))
            #expect(!policy.recordCheckIn(on: today, now: today))
        }
    }

    @Test("The same calendar day counts once even across midnight in UTC")
    func localDay() throws {
        try withPolicy { _, defaults in
            var localCalendar = calendar
            localCalendar.timeZone = try #require(TimeZone(identifier: "America/New_York"))
            let policy = ReviewRequestPolicy(defaults: defaults, version: "1.0", calendar: localCalendar)
            let evening = try Date("2026-10-01T23:00:00Z", strategy: .iso8601)
            let sameEvening = try Date("2026-10-02T02:00:00Z", strategy: .iso8601)
            #expect(!policy.recordCheckIn(on: evening, now: evening))
            #expect(!policy.recordCheckIn(on: sameEvening, now: sameEvening))
            #expect(!policy.recordCheckIn(on: evening.addingTimeInterval(86_400), now: evening.addingTimeInterval(86_400)))
            #expect(policy.recordCheckIn(on: evening.addingTimeInterval(172_800), now: evening.addingTimeInterval(172_800)))
        }
    }

    @Test("An attempt requires a new version, a two-week cooldown, and additional engagement")
    func attemptLimits() throws {
        try withPolicy { policy, defaults in
            try earnCheckIns(policy, days: 0..<3)
            #expect(policy.claimRequest(now: try day(2)))
            #expect(!policy.claimRequest(now: try day(2)))
            try earnCheckIns(policy, days: 3..<6)
            #expect(!policy.isEligible(now: try day(20)))

            let update = ReviewRequestPolicy(defaults: defaults, version: "1.1", calendar: calendar)
            #expect(!update.claimRequest(now: try day(15)))
            #expect(update.claimRequest(now: try day(16)))
            #expect(!update.claimRequest(now: try day(100)))
        }
    }

    @Test("A new version and elapsed time alone aren't enough to ask again")
    func additionalEngagement() throws {
        try withPolicy { policy, defaults in
            try earnCheckIns(policy, days: 0..<3)
            #expect(policy.claimRequest(now: try day(2)))
            let update = ReviewRequestPolicy(defaults: defaults, version: "1.1", calendar: calendar)
            #expect(!update.isEligible(now: try day(30)))
            #expect(!update.recordCheckIn(on: try day(30), now: try day(30)))
            #expect(!update.recordCheckIn(on: try day(31), now: try day(31)))
            #expect(update.recordCheckIn(on: try day(32), now: try day(32)))
        }
    }

    @Test("A second window cannot repeat an attempt even when StoreKit suppresses the prompt")
    func sharedAttemptHistory() throws {
        try withPolicy { firstWindow, defaults in
            let secondWindow = ReviewRequestPolicy(defaults: defaults, version: "1.0", calendar: calendar)
            try earnCheckIns(firstWindow, days: 0..<3)
            #expect(secondWindow.isEligible(now: try day(2)))
            #expect(firstWindow.claimRequest(now: try day(2)))
            #expect(!secondWindow.claimRequest(now: try day(2)))
        }
    }

    @Test("A missing app version never permits a request")
    func missingVersion() throws {
        try withPolicy { _, defaults in
            let policy = ReviewRequestPolicy(defaults: defaults, version: nil, calendar: calendar)
            try earnCheckIns(policy, days: 0..<3)
            #expect(!policy.claimRequest(now: try day(2)))
        }
    }

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar
    }

    private func day(_ offset: Int) throws -> Date {
        try Date("2026-10-01T12:00:00Z", strategy: .iso8601)
            .addingTimeInterval(Double(offset) * 86_400)
    }

    private func earnCheckIns(_ policy: ReviewRequestPolicy, days: Range<Int>) throws {
        for offset in days {
            let date = try day(offset)
            policy.recordCheckIn(on: date, now: date)
        }
    }

    private func withPolicy(_ body: (ReviewRequestPolicy, UserDefaults) throws -> Void) throws {
        let suite = "ReviewRequestPolicyTests-\(UUID())"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        try body(ReviewRequestPolicy(defaults: defaults, version: "1.0", calendar: calendar), defaults)
    }
}
