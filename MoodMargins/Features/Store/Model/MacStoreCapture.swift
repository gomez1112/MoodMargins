#if DEBUG && os(macOS)
import AppKit
import AVFoundation
import ScreenCaptureKit
import SwiftUI

/// Captures the actual SwiftUI app window, including native window chrome.
/// The explicit capture flag requires the separate fictional journal store.
/// ScreenCaptureKit is necessary to include Metal-backed Lottie animations.
@MainActor
final class MacStoreCapture: NSObject, SCRecordingOutputDelegate {
    private var recordingFinished = false
    private var recordingFailure: String?

    static func export(navigation: NavigationContext, preview: MarketingCaptureState) async throws {
        let recorder = MacStoreCapture()
        try await recorder.exportWindow(navigation: navigation, preview: preview)
    }

    private func exportWindow(navigation: NavigationContext, preview: MarketingCaptureState) async throws {
        try await Task.sleep(for: .seconds(2))
        guard let window = NSApplication.shared.windows.first(where: { $0.isVisible && $0.contentView != nil }) else {
            throw CaptureError.missingWindow
        }
        window.setContentSize(NSSize(width: 1200, height: 750))
        window.center()
        window.makeKeyAndOrderFront(nil)
        let language = preview.locale?.language.languageCode?.identifier ?? "en"
        let directory = URL.documentsDirectory.appending(path: "MoodMargins-Captures/\(language)", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let content = try await SCShareableContent.currentProcess
        guard let ownWindow = content.windows.first(where: { $0.windowID == window.windowNumber }) else {
            throw CaptureError.missingWindow
        }
        let filter = SCContentFilter(desktopIndependentWindow: ownWindow)
        let still = SCStreamConfiguration()
        still.width = Int(window.frame.width * 2)
        still.height = Int(window.frame.height * 2)
        still.showsCursor = false
        still.ignoreShadowsSingleWindow = true

        // Capture dark appearance in a separate launch. Changing a native
        // window's appearance during ScreenCaptureKit capture can replace it.
        if ProcessInfo.processInfo.arguments.contains("--marketing-dark") {
            navigation.selectedTab = .insights
            try await Task.sleep(for: .seconds(2))
            try await screenshot("dark", filter: filter, configuration: still, directory: directory)
            signalCompletion()
            return
        }

        if ProcessInfo.processInfo.arguments.contains("--marketing-stickers-only") {
            navigation.selectedTab = .insights
            try await Task.sleep(for: .seconds(2))
            scrollInsights(in: window, toStickers: true)
            try await Task.sleep(for: .milliseconds(300))
            try await screenshot("stickers", filter: filter, configuration: still, directory: directory)
            signalCompletion()
            return
        }

        for (name, tab) in [("today", AppTab.today), ("pages", .page), ("insights", .insights), ("stickers", .insights), ("customize", .customize)] {
            navigation.selectedTab = tab
            try await Task.sleep(for: .seconds(2))
            if name == "stickers" {
                scrollInsights(in: window, toStickers: true)
                try await Task.sleep(for: .milliseconds(300))
            }
            try await screenshot(name, filter: filter, configuration: still, directory: directory)
            if name == "stickers" { scrollInsights(in: window, toStickers: false) }
        }
        for theme in [DiaryTheme.botanical, .coastal, .sunset] {
            navigation.customizePath.append(theme)
            try await Task.sleep(for: .seconds(2))
            try await screenshot(theme.rawValue, filter: filter, configuration: still, directory: directory)
            navigation.customizePath.removeLast()
        }
        navigation.selectedTab = .today
        try await Task.sleep(for: .seconds(2))

        let video = SCStreamConfiguration()
        video.width = 1920
        video.height = 1080
        video.minimumFrameInterval = CMTime(value: 1, timescale: 30)
        video.scalesToFit = true
        let previewBackground = CGColor(red: 1, green: 0.93, blue: 0.95, alpha: 1)
        video.backgroundColor = previewBackground
        // ScreenCaptureKit keeps an unretained reference to this color.
        defer { withExtendedLifetime(previewBackground) {} }
        video.showsCursor = false
        video.capturesAudio = false
        video.ignoreShadowsSingleWindow = true
        let recording = SCRecordingOutputConfiguration()
        recording.outputURL = directory.appending(path: "mac-preview-raw.mp4")
        recording.videoCodecType = .h264
        recording.outputFileType = .mp4
        let stream = SCStream(filter: filter, configuration: video, delegate: nil)
        try stream.addRecordingOutput(SCRecordingOutput(configuration: recording, delegate: self))
        try await stream.startCapture()
        do {
            // Deliberate viewing intervals record the live UI and animated faces.
            for tab in [AppTab.today, .page, .insights, .customize] {
                navigation.selectedTab = tab
                try await Task.sleep(for: .seconds(5))
            }
            try await stream.stopCapture()
        } catch {
            do { try await stream.stopCapture() } catch { print("Capture cleanup failed: \(error)") }
            throw error
        }
        let deadline = ContinuousClock.now.advanced(by: .seconds(10))
        while !recordingFinished && recordingFailure == nil && ContinuousClock.now < deadline {
            try await Task.sleep(for: .milliseconds(100))
        }
        if let recordingFailure { throw CaptureError.recording(recordingFailure) }
        guard recordingFinished else { throw CaptureError.recording("Video finalization timed out.") }
        // LaunchServices supplies the output file descriptor. Export only assets
        // this capture created, so tools never need access to the private journal
        // container or the user's Screen Recording permission.
        try emitAsset("mac-preview-raw.mp4", data: Data(contentsOf: recording.outputURL))
        try Data("Captured the native app window and preview.\n".utf8).write(to: directory.appending(path: "mac-capture-complete.txt"))
        signalCompletion()
    }

    private func screenshot(_ name: String, filter: SCContentFilter, configuration: SCStreamConfiguration, directory: URL) async throws {
        NSApplication.shared.activate()
        let image = try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: configuration)
        guard let data = NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:]) else {
            throw CaptureError.imageEncoding
        }
        try data.write(to: directory.appending(path: "mac-\(name).png"))
        try emitAsset("mac-\(name).png", data: data)
    }

    private func scrollInsights(in window: NSWindow, toStickers: Bool) {
        func findContentScrollView(in view: NSView) -> NSScrollView? {
            if let scroll = view as? NSScrollView,
               !scroll.isHiddenOrHasHiddenAncestor,
               scroll.frame.width > window.contentLayoutRect.width / 2,
               let document = scroll.documentView,
               document.bounds.height > scroll.contentView.bounds.height {
                return scroll
            }
            return view.subviews.lazy.compactMap { findContentScrollView(in: $0) }.first
        }
        guard let root = window.contentView, let scroll = findContentScrollView(in: root), let document = scroll.documentView else { return }
        let offset = toStickers ? min(340, document.bounds.height - scroll.contentView.bounds.height) : 0
        scroll.contentView.scroll(to: NSPoint(x: 0, y: offset))
        scroll.reflectScrolledClipView(scroll.contentView)
    }

    private func emitAsset(_ filename: String, data: Data) throws {
        let payload = try JSONEncoder().encode(CaptureAsset(filename: filename, data: data))
        FileHandle.standardOutput.write(Data("STORE_ASSET:".utf8) + payload + Data("\n".utf8))
    }

    private func signalCompletion() {
        // A LaunchServices file descriptor is not a terminal; print buffers
        // completion markers until process exit. Write the marker directly.
        FileHandle.standardOutput.write(Data("STORE_CAPTURE_COMPLETE\n".utf8))
    }

    nonisolated func recordingOutputDidFinishRecording(_ recordingOutput: SCRecordingOutput) {
        Task { @MainActor in recordingFinished = true }
    }

    nonisolated func recordingOutput(_ recordingOutput: SCRecordingOutput, didFailWithError error: any Error) {
        let message = error.localizedDescription
        Task { @MainActor in recordingFailure = message }
    }
}

private enum CaptureError: Error {
    case missingWindow, imageEncoding, recording(String)
}

private struct CaptureAsset: Encodable {
    var filename: String
    var data: Data
}
#endif
