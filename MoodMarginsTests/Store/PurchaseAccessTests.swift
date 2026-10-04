import Foundation
import Testing
@testable import MoodMargins

@Suite("Purchase access")
@MainActor
struct PurchaseAccessTests {
    @Test("Every billing plan unlocks the same Plus features", arguments: StoreProduct.subscriptions)
    func sameTier(product: StoreProduct) {
        let access = PurchaseEntitlements(products: [product])
        #expect(access.hasPlus)
        #expect(DiaryTheme.allCases.allSatisfy(access.canUse))
        #expect(!access.owns(.botanical))
    }

    @Test("Permanent themes survive subscription expiry and do not unlock AI")
    func permanentOwnership() {
        let purchased = PurchaseEntitlements(products: [.coastal])
        #expect(purchased.canUse(.pastel))
        #expect(purchased.canUse(.coastal))
        #expect(!purchased.canUse(.sunset))
        #expect(!purchased.hasPlus)
        #expect(!PurchaseEntitlements().canUse(.coastal))
    }

    @Test("Selection persists and unavailable access preserves the preference")
    func themePreferences() throws {
        let suite = "MoodMargins.ThemeTests.\(UUID())"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let preferences = ThemePreferences(defaults: defaults)
        let plus = PurchaseEntitlements(products: [.yearly])
        #expect(!preferences.select(.sunset, access: .init()))
        #expect(preferences.selectedTheme == .pastel)
        #expect(preferences.select(.sunset, access: plus))
        let reopened = ThemePreferences(defaults: defaults)
        #expect(reopened.effectiveTheme(access: plus) == .sunset)
        #expect(reopened.effectiveTheme(access: .init()) == .pastel)
        #expect(reopened.selectedTheme == .sunset)
        #expect(reopened.effectiveTheme(access: .init(products: [.sunset])) == .sunset)
    }

    @Test("Losing Plus clears generated tags without changing a journal draft")
    func freeTagging() async {
        let model = TodayViewModel()
        model.note = "A long enough private draft that must not be sent for AI."
        model.selectedTags = ["rest"]
        model.generatedTagSuggestions = ["quiet"]
        model.tagSuggestionError = "Old error"
        await model.generateTagSuggestions(using: .privateCloudCompute, hasPlus: false)
        #expect(model.generatedTagSuggestions.isEmpty)
        #expect(model.tagSuggestionError == nil)
        #expect(!model.isGeneratingTagSuggestions)
        #expect(model.note.hasPrefix("A long enough private draft"))
        #expect(model.selectedTags == ["rest"])
    }
}
