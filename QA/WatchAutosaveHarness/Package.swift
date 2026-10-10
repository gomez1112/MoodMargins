// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "MoodMarginsWatchAutosaveChecks",
    platforms: [.macOS("27.0")],
    targets: [
        .target(name: "WatchJournalModel"),
        .testTarget(name: "WatchJournalModelTests", dependencies: ["WatchJournalModel"])
    ],
    swiftLanguageModes: [.v6]
)
