import Foundation

/// Local engagement and attempt history, independent of mood, purchases, and feedback.
/// Read the shared defaults on every operation so multiple windows cannot claim the same attempt.
@MainActor
struct ReviewRequestPolicy {
    private let defaults: UserDefaults
    private let version: String?
    private let calendar: Calendar
    private let storageKey = "journalReviewRequestHistory"
    private let requiredCheckInDays = 3

    init(
        defaults: UserDefaults = .standard,
        version: String? = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
        calendar: Calendar = Calendar(identifier: .gregorian)
    ) {
        self.defaults = defaults
        self.version = version
        self.calendar = calendar
    }

    /// Only actual saves for today count. Loading, syncing, and editing older pages do not.
    /// Repeated autosaves on the same day contribute just one check-in.
    @discardableResult
    func recordCheckIn(on entryDate: Date, now: Date = .now) -> Bool {
        guard calendar.isDate(entryDate, inSameDayAs: now) else { return false }
        let components = calendar.dateComponents([.year, .month, .day], from: entryDate)
        guard let year = components.year, let month = components.month, let day = components.day else { return false }
        let dayKey = year * 10_000 + month * 100 + day
        var history = history
        if dayKey > (history["lastCheckInDay"] as? Int ?? 0) {
            history["lastCheckInDay"] = dayKey
            history["checkInDays"] = min(requiredCheckInDays, (history["checkInDays"] as? Int ?? 0) + 1)
            defaults.set(history, forKey: storageKey)
        }
        return isEligible(now: now)
    }

    func isEligible(now: Date = .now) -> Bool {
        let history = history
        guard let version, !version.isEmpty,
              history["lastAttemptedVersion"] as? String != version,
              (history["checkInDays"] as? Int ?? 0) >= requiredCheckInDays else { return false }
        if let lastAttempt = history["lastAttemptDate"] as? Date {
            guard let nextAttempt = calendar.date(byAdding: .day, value: 14, to: lastAttempt),
                  now >= nextAttempt else { return false }
        }
        return true
    }

    /// StoreKit doesn't report whether it displayed a prompt or received a review.
    /// Record the attempt before calling it, including when the system suppresses its UI.
    func claimRequest(now: Date = .now) -> Bool {
        guard isEligible(now: now), let version else { return false }
        var history = history
        history["lastAttemptedVersion"] = version
        history["lastAttemptDate"] = now
        history["checkInDays"] = 0
        defaults.set(history, forKey: storageKey)
        return true
    }

    private var history: [String: Any] {
        defaults.dictionary(forKey: storageKey) ?? [:]
    }
}
