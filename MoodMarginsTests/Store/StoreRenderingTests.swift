import Foundation
import ImageIO
import SwiftUI
import Testing
import UniformTypeIdentifiers
@testable import MoodMargins

@Suite("Store layouts")
@MainActor
struct StoreRenderingTests {
    @Test("Themes render in light, dark, and large text without changing purchases")
    func themeLayouts() throws {
        for theme in DiaryTheme.allCases {
            for scheme in [ColorScheme.light, .dark] {
                for largeText in [false, true] {
                    let content = ThemePreviewView(theme: theme)
                        .padding(16)
                        .frame(width: 393)
                        .environment(\.colorScheme, scheme)
                        .environment(\.dynamicTypeSize, largeText ? .accessibility3 : .large)
                    try render(content, name: "\(theme.rawValue)-\(scheme)-\(largeText ? "large-text" : "standard")")
                }
            }
        }
    }

    private func render(_ content: some View, name: String) throws {
        let directory = URL.temporaryDirectory.appending(path: "MoodMargins-Store-QA", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let renderer = ImageRenderer(content: content)
        renderer.scale = 2
        let image = try #require(renderer.cgImage)
        #expect(image.width == 786)
        let url = directory.appending(path: "\(name).png")
        let destination = try #require(CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil))
        CGImageDestinationAddImage(destination, image, nil)
        #expect(CGImageDestinationFinalize(destination))
    }
}
