import Foundation
import StoreKit

enum PurchaseErrorPresenter {
    /// Cancellation is silent; failures explain the action a person can take next.
    static func message(for error: Error) -> String? {
        if error is CancellationError { return nil }
        if let error = error as? URLError {
            return error.code == .cancelled ? nil : String(localized: .purchaseNetworkError)
        }
        if let error = error as? StoreKitError {
            switch error {
            case .userCancelled: return nil
            case .networkError(let underlying): return message(for: underlying)
            case .notAvailableInStorefront: return String(localized: .purchaseStorefrontError)
            case .systemError(let underlying): return message(for: underlying)
            default: break
            }
        }
        if let error = error as? Product.PurchaseError {
            switch error {
            case .purchaseNotAllowed: return String(localized: .purchaseRestrictedError)
            case .productUnavailable: return String(localized: .purchaseProductUnavailable)
            default: break
            }
        }
        if let error = error as? SKError {
            switch error.code {
            case .paymentCancelled: return nil
            case .paymentNotAllowed: return String(localized: .purchaseRestrictedError)
            case .storeProductNotAvailable: return String(localized: .purchaseStorefrontError)
            case .cloudServiceNetworkConnectionFailed: return String(localized: .purchaseNetworkError)
            default: break
            }
        }
        return String(localized: .purchaseTemporaryError)
    }
}
