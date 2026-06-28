//
//  MoodEntryModelTests.swift
//  MoodMarginsTests
//
//  Created by Gerard Gomez on 6/28/26.
//

import Testing
@testable import MoodMargins

@Suite("Mood entry model", .serialized)
@MainActor
struct MoodEntryModelTests {
    struct FractionScenario: Sendable, CustomTestStringConvertible {
        let name: String
        let sleepQuality: Int
        let energyLevel: Int
        let expectedSleepFraction: Double
        let expectedEnergyFraction: Double

        var testDescription: String { name }
    }

    @Test(
        "Sleep and energy fractions map integer scores onto 0...1 scale",
        arguments: [
            FractionScenario(name: "minimum values", sleepQuality: 0, energyLevel: 0, expectedSleepFraction: 0, expectedEnergyFraction: 0),
            FractionScenario(name: "middle values", sleepQuality: 3, energyLevel: 2, expectedSleepFraction: 0.6, expectedEnergyFraction: 0.4),
            FractionScenario(name: "maximum values", sleepQuality: 5, energyLevel: 5, expectedSleepFraction: 1, expectedEnergyFraction: 1)
        ]
    )
    func fractions(_ scenario: FractionScenario) {
        let entry = TestFactory.entry(sleepQuality: scenario.sleepQuality, energyLevel: scenario.energyLevel)

        #expect(entry.sleepFraction == scenario.expectedSleepFraction)
        #expect(entry.energyFraction == scenario.expectedEnergyFraction)
    }
}
