import Foundation
import Observation

@MainActor
@Observable
final class FoundationModelPreferences {
    static let storageKey = "foundationModelChoice"
    private let defaults: UserDefaults

    var choice: FoundationModelChoice {
        didSet { defaults.set(choice.rawValue, forKey: Self.storageKey) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        choice = defaults.string(forKey: Self.storageKey).flatMap(FoundationModelChoice.init(rawValue:)) ?? .onDevice
    }
}
