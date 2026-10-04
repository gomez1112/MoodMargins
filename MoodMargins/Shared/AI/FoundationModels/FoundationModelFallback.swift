import Foundation

/// Retries a failed cloud request once on device. Cancellation never starts another request.
@MainActor
enum FoundationModelFallback {
    static func run(preferred choice: FoundationModelChoice, operation: (FoundationModelChoice) async throws -> Void) async throws {
        try Task.checkCancellation()
        do {
            try await operation(choice)
        } catch {
            try Task.checkCancellation()
            guard choice == .privateCloudCompute, !(error is CancellationError) else { throw error }
            try await operation(.onDevice)
        }
    }
}
