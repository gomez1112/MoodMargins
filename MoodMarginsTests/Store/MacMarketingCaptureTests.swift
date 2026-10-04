#if os(macOS)
import AppKit
import SwiftUI
import SwiftData
import ScreenCaptureKit
import DotLottie
import MetalKit
import XCTest
@testable import MoodMargins

/// An opt-in export of the app's native Mac views. This captures only our own
/// window and uses a separate local store, without Accessibility automation.
final class MacMarketingCaptureTests: XCTestCase {
    @MainActor
    func testExportNativeMacScreens() async throws {
        guard ProcessInfo.processInfo.environment["MOODMARGINS_EXPORT_MAC"] == "1" else {
            throw XCTSkip("Native marketing capture is opt-in.")
        }
        let preview = MarketingCaptureState(isCaptureSession: true)
        let container = try XCTUnwrap(preview.container)
        let locale = ProcessInfo.processInfo.environment["MOODMARGINS_CAPTURE_LANGUAGE"] ?? "en"
        let directory = URL.temporaryDirectory.appending(path: "MoodMargins-Captures/\(locale)", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        for (name, tab, scheme) in [("today", AppTab.today, ColorScheme.light), ("pages", .page, .light), ("insights", .insights, .light), ("dark", .insights, .dark)] {
            let navigation = NavigationContext()
            navigation.selectedTab = tab
            let purchases = PurchaseStore()
            let themes = ThemePreferences()
            let root = Group {
                switch tab {
                case .today: TodayView()
                case .page: PageView()
                case .insights: InsightsView()
                case .customize: StoreView()
                }
            }
                .environment(navigation).environment(purchases).environment(themes)
                .environment(FoundationModelPreferences()).environment(preview)
                .environment(\.diaryPalette, DiaryTheme.pastel.palette)
                .environment(\.locale, Locale(identifier: locale))
                .environment(\.layoutDirection, locale == "ar" ? .rightToLeft : .leftToRight)
                .preferredColorScheme(scheme)
                .modelContainer(container)
                // Present the app content with the window toolbar hidden for the artwork.
                .toolbar(.hidden, for: .windowToolbar)
            let controller = NSHostingController(rootView: root)
            let host = controller.view
            host.frame = NSRect(x: 0, y: 0, width: 1200, height: 850)
            host.autoresizingMask = [.width, .height]
            let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1200, height: 850), styleMask: [.borderless], backing: .buffered, defer: false)
            window.title = "MoodMargins"
            window.contentViewController = controller
            // Keep captures on the primary display, including in RTL locales.
            let captureMargin: CGFloat = 24
            window.setFrameOrigin(NSPoint(x: captureMargin, y: captureMargin))
            window.makeKeyAndOrderFront(nil)
            NSApplication.shared.activate()
            defer { window.orderOut(nil) }
            host.layoutSubtreeIfNeeded()
            let clock = ContinuousClock()
            let deadline = clock.now.advanced(by: .seconds(10))
            while clock.now < deadline {
                host.layoutSubtreeIfNeeded()
                let animations = descendants(of: host).compactMap { $0 as? DotLottieAnimationView }
                if !animations.isEmpty && animations.allSatisfy({ $0.dotLottieViewModel.isLoaded() }) {
                    for metal in descendants(of: host).compactMap({ $0 as? MTKView }) { metal.draw() }
                    if animations.allSatisfy({ $0.dotLottieViewModel.currentFrame() > 0 }) { break }
                }
                try await clock.sleep(for: .milliseconds(50))
            }
            let animations = descendants(of: host).compactMap { $0 as? DotLottieAnimationView }
            XCTAssertFalse(animations.isEmpty)
            XCTAssertTrue(animations.allSatisfy { $0.dotLottieViewModel.isLoaded() })
            window.toolbar?.isVisible = false
            host.needsLayout = true
            host.layoutSubtreeIfNeeded()
            // Query only this process's own windows, never the user's desktop.
            let content = try await SCShareableContent.currentProcess
            let ownWindow = try XCTUnwrap(content.windows.first { $0.windowID == window.windowNumber })
            let filter = SCContentFilter(desktopIndependentWindow: ownWindow)
            let configuration = SCStreamConfiguration()
            configuration.width = Int(window.frame.width * 2)
            configuration.height = Int(window.frame.height * 2)
            configuration.showsCursor = false
            configuration.ignoreShadowsSingleWindow = true
            let image = try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: configuration)
            let bitmap = NSBitmapImageRep(cgImage: image)
            let data = try XCTUnwrap(bitmap.representation(using: .png, properties: [:]))
            try data.write(to: directory.appending(path: "mac-\(name).png"))
        }
    }

    @MainActor
    private func descendants(of view: NSView) -> [NSView] {
        view.subviews.flatMap { [$0] + descendants(of: $0) }
    }
}
#endif
