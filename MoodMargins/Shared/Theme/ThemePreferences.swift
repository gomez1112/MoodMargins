import Foundation
import Observation

@MainActor
@Observable
final class ThemePreferences {
    private let defaults: UserDefaults
    private static let storageKey = "selectedDiaryTheme"
    private(set) var selectedTheme: DiaryTheme

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        selectedTheme = defaults.string(forKey: Self.storageKey).flatMap(DiaryTheme.init(rawValue:)) ?? .pastel
    }

    /// Access can lapse without losing the person's preference or any journal draft.
    func effectiveTheme(access: PurchaseEntitlements) -> DiaryTheme {
        access.canUse(selectedTheme) ? selectedTheme : .pastel
    }

    @discardableResult
    func select(_ theme: DiaryTheme, access: PurchaseEntitlements) -> Bool {
        guard access.canUse(theme) else { return false }
        selectedTheme = theme
        defaults.set(theme.rawValue, forKey: Self.storageKey)
        return true
    }
}
