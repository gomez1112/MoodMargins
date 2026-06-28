//
//  TestFactory.swift
//  MoodMarginsTests
//
//  Created by Gerard Gomez on 6/28/26.
//

import Foundation
import SwiftData
@testable import MoodMargins

@MainActor
enum TestFactory {
    private static let inMemoryStoreLock = NSLock()
    private static var retainedModelContainers: [ModelContainer] = []

    static func entry(
        date: Date = Date(),
        mood: Mood = .wink,
        note: String = "",
        tags: [String] = [],
        activities: [Activity]? = nil,
        sleepQuality: Int = 3,
        energyLevel: Int = 3
    ) -> MoodEntry {
        MoodEntry(
            date: date,
            mood: mood,
            note: note,
            tags: tags,
            activities: activities,
            sleepQuality: sleepQuality,
            energyLevel: energyLevel
        )
    }

    static func activity(title: String, symbol: String = "circle") -> Activity {
        Activity(title: title, symbol: symbol)
    }

    static func date(daysAgo: Int) -> Date {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        return calendar.date(byAdding: .day, value: -daysAgo, to: startOfToday) ?? startOfToday
    }

    static func lockInMemoryStore() {
        inMemoryStoreLock.lock()
    }

    static func unlockInMemoryStore() {
        retainedModelContainers.removeAll()
        inMemoryStoreLock.unlock()
    }

    static func inMemoryModelContext() throws -> ModelContext {
        let schema = Schema([MoodEntry.self, Activity.self])
        let configuration = ModelConfiguration("Test-\(UUID().uuidString)", schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        retainedModelContainers.append(container)
        return ModelContext(container)
    }

    static func resetInMemoryModelContainers() {
        retainedModelContainers.removeAll()
    }
}
