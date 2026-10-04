import Foundation
import Testing
@testable import MoodMargins

@Suite("Cloud to local fallback")
@MainActor
struct FoundationModelFallbackTests {
    private enum TestFailure: Error { case cloud, local }

    @Test("A cloud failure retries once on device")
    func cloudFailure() async throws {
        var attempts: [FoundationModelChoice] = []
        try await FoundationModelFallback.run(preferred: .privateCloudCompute) { choice in
            attempts.append(choice)
            if choice == .privateCloudCompute { throw TestFailure.cloud }
        }
        #expect(attempts == [.privateCloudCompute, .onDevice])
    }

    @Test("Successful cloud requests do not spend a second generation")
    func cloudSuccess() async throws {
        var attempts: [FoundationModelChoice] = []
        try await FoundationModelFallback.run(preferred: .privateCloudCompute) { attempts.append($0) }
        #expect(attempts == [.privateCloudCompute])
    }

    @Test("Turning cloud off never sends a cloud request, even if local fails")
    func localOnly() async {
        var attempts: [FoundationModelChoice] = []
        do {
            try await FoundationModelFallback.run(preferred: .onDevice) {
                attempts.append($0)
                throw TestFailure.local
            }
            Issue.record("Expected the local failure")
        } catch { #expect(error as? TestFailure == .local) }
        #expect(attempts == [.onDevice])
    }

    @Test("Cancellation never retries on device")
    func cancellation() async {
        var attempts: [FoundationModelChoice] = []
        do {
            try await FoundationModelFallback.run(preferred: .privateCloudCompute) {
                attempts.append($0)
                throw CancellationError()
            }
            Issue.record("Expected cancellation")
        } catch { #expect(error is CancellationError) }
        #expect(attempts == [.privateCloudCompute])
    }

    @Test("If both models fail, the local failure reaches the UI")
    func bothFail() async {
        var attempts: [FoundationModelChoice] = []
        do {
            try await FoundationModelFallback.run(preferred: .privateCloudCompute) {
                attempts.append($0)
                throw $0 == .privateCloudCompute ? TestFailure.cloud : TestFailure.local
            }
            Issue.record("Expected the local failure")
        } catch { #expect(error as? TestFailure == .local) }
        #expect(attempts == [.privateCloudCompute, .onDevice])
    }
}
