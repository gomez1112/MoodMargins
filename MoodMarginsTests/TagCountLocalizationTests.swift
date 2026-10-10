import Foundation
import Testing

@Suite("Journal tag-count localization")
struct TagCountLocalizationTests {
    @Test("English and Spanish use singular for one tag", arguments: ["en", "es", "es-US", "es-419"])
    func singularAndPlural(language: String) throws {
        let expected = language == "en" ? ["0 tags", "1 tag", "2 tags"] : ["0 etiquetas", "1 etiqueta", "2 etiquetas"]
        for (count, suffix) in expected.enumerated() {
            #expect(try status(count: count, language: language) == "Saved · \(suffix)")
        }
    }

    @Test("Arabic selects each plural form", arguments: [0, 1, 2, 3, 11, 100])
    func arabic(count: Int) throws {
        let suffix = switch count {
        case 2: "وسمان"
        case 3: "وسوم"
        case 11: "وسمًا"
        default: "وسم"
        }
        let text = try status(count: count, language: "ar")
        #expect(text.hasPrefix("Saved · "))
        #expect(text.hasSuffix(suffix))
        #expect(!text.contains("%"))
    }

    private func status(count: Int, language: String) throws -> String {
        let url = try #require(Bundle.main.url(forResource: language, withExtension: "lproj"))
        let bundle = try #require(Bundle(url: url))
        return String(localized: "\("Saved") · \(count) tags", bundle: bundle, locale: Locale(identifier: language))
    }
}
