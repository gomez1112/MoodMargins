import Foundation

enum FoundationModelChoice: String, CaseIterable, Identifiable, Sendable {
    case onDevice
    case privateCloudCompute

    var id: Self { self }

    var title: String {
        switch self {
        case .onDevice: String(localized: "On this device")
        case .privateCloudCompute: String(localized: "Private Cloud Compute")
        }
    }

    var explanation: String {
        switch self {
        case .onDevice:
            String(localized: "Generate tags and recaps on this device.")
        case .privateCloudCompute:
            String(localized: "Generate tags and recaps with Apple's Private Cloud Compute. Journal text used for generation is sent for processing. An internet connection is required.")
        }
    }
}
