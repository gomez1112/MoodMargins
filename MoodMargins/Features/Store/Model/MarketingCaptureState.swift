#if DEBUG
import Foundation
import Observation
import SwiftData
import SwiftUI

/// A separate, local-only preview store. It never changes or synchronizes the person's journal.
@MainActor
@Observable
final class MarketingCaptureState {
    private(set) var container: ModelContainer?
    var errorMessage: String?
    var language: String = UserDefaults.standard.string(forKey: "marketingCaptureLanguage") ?? "en" {
        didSet {
            defaults.set(language, forKey: "marketingCaptureLanguage")
            // This app-scoped override is restored when the isolated capture mode ends.
            defaults.set([language], forKey: "AppleLanguages")
        }
    }
    var usesDarkAppearance = UserDefaults.standard.bool(forKey: "marketingCaptureDark") {
        didSet { defaults.set(usesDarkAppearance, forKey: "marketingCaptureDark") }
    }
    private let defaults = UserDefaults.standard
    private let storageKey = "marketingPreviewEnabled"
    private let isCaptureSession: Bool
    var isEnabled: Bool { container != nil }
    var appearance: ColorScheme? {
        guard isEnabled else { return nil }
        return ProcessInfo.processInfo.arguments.contains("--marketing-dark") || usesDarkAppearance ? .dark : .light
    }
    var locale: Locale? {
        let arguments = ProcessInfo.processInfo.arguments
        guard isCaptureSession,
              let index = arguments.firstIndex(of: "-AppleLocale"),
              arguments.indices.contains(index + 1) else { return isEnabled ? Locale(identifier: language) : nil }
        // SwiftUI's environment locale can differ from the test process's preferred bundle language.
        return Locale(identifier: arguments[index + 1])
    }

    init(isCaptureSession: Bool = ProcessInfo.processInfo.arguments.contains("--marketing-capture")) {
        self.isCaptureSession = isCaptureSession
        if isCaptureSession || defaults.bool(forKey: storageKey) { setEnabled(true) }
    }

    func setEnabled(_ enabled: Bool) {
        if !enabled {
            container = nil
            if !isCaptureSession {
                defaults.set(false, forKey: storageKey)
                if let originalLanguages = defaults.array(forKey: "marketingOriginalLanguages") {
                    defaults.set(originalLanguages, forKey: "AppleLanguages")
                } else {
                    defaults.removeObject(forKey: "AppleLanguages")
                }
                defaults.removeObject(forKey: "marketingOriginalLanguages")
                defaults.removeObject(forKey: "marketingCapturedLanguageBaseline")
            }
            return
        }
        guard container == nil else { return }
        if !isCaptureSession, !defaults.bool(forKey: "marketingCapturedLanguageBaseline") {
            if let originalLanguages = defaults.array(forKey: "AppleLanguages") {
                defaults.set(originalLanguages, forKey: "marketingOriginalLanguages")
            }
            defaults.set(true, forKey: "marketingCapturedLanguageBaseline")
        }
        do {
            let schema = Schema([MoodEntry.self, Activity.self])
            let configuration = ModelConfiguration("MarketingPreview", schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
            let preview = try ModelContainer(for: schema, configurations: [configuration])
            let context = preview.mainContext
            let calendar = Calendar.current
            let notes = [
                String(localized: "A slow walk, a warm cup of tea, and a little time for myself."),
                String(localized: "A full day. I gave myself permission to rest."),
                String(localized: "Tea and a long catch-up with a friend. I laughed more than I expected."),
                String(localized: "Spent the afternoon reading with the window open."),
                String(localized: "A small pause helped me feel a little steadier."),
                String(localized: "Made time for music and a quiet evening."),
                String(localized: "An easy morning outside. Noticed the first autumn leaves.")
            ]
            let moods: [Mood] = [.wink, .mourn, .laughing, .wink, .sad, .mourn, .laughing]
            for age in 0..<14 where age != 5 {
                guard let date = calendar.date(byAdding: .day, value: -age, to: Date()) else { continue }
                let index = age % notes.count
                context.insert(MoodEntry(date: date, mood: moods[index], note: notes[index], tags: age % 3 == 0 ? [String(localized: "calm"), String(localized: "outdoors")] : [String(localized: "rest"), String(localized: "grateful")], activities: [Activity(title: String(localized: "Reading"), symbol: "book.closed")], sleepQuality: 3, energyLevel: 3))
            }
            try context.save()
            container = preview
            if !isCaptureSession { defaults.set(true, forKey: storageKey) }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
#endif
