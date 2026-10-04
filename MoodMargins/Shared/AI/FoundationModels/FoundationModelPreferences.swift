import Foundation
import Observation

@MainActor
@Observable
final class FoundationModelPreferences {
    static let storageKey = "usesPrivateCloudCompute"
    private let defaults: UserDefaults

    var usesPrivateCloudCompute: Bool {
        didSet { defaults.set(usesPrivateCloudCompute, forKey: Self.storageKey) }
    }

    var choice: FoundationModelChoice { usesPrivateCloudCompute ? .privateCloudCompute : .onDevice }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        usesPrivateCloudCompute = defaults.object(forKey: Self.storageKey) as? Bool ?? true
    }
}
