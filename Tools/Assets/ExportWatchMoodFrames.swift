import CoreGraphics
import DotLottiePlayer
import Foundation
import ImageIO

/// Run with the existing DotLottiePlayer macOS framework; no new dependency is needed.
/// Watch playback uses these exact Lottie frames without a continuously running vector renderer.
@main
struct ExportWatchMoodFrames {
    static func main() throws {
        guard CommandLine.arguments.count == 2 else { throw ExportError.invalidArguments }
        let root = URL(filePath: CommandLine.arguments[1], directoryHint: .isDirectory)
        let output = root.appending(path: "WatchMoodMargins Watch App/Assets.xcassets")
        let size = 160
        let fps = 15.0
        var counts: [String: Int] = [:]
        var durations: [String: Double] = [:]
        for name in ["angry", "sad", "mourn", "wink", "laughing"] {
            guard let player = dotlottie_new_player(0) else { throw ExportError.renderer("Create player") }
            defer { dotlottie_destroy(player) }
            var pixels = [UInt32](repeating: 0, count: size * size)
            try pixels.withUnsafeMutableBufferPointer { buffer in
                guard let baseAddress = buffer.baseAddress,
                      dotlottie_set_sw_target(player, baseAddress, UInt32(size), UInt32(size), ABGR8888) == Success else {
                    throw ExportError.renderer("Software target")
                }
                let input = root.appending(path: "MoodMargins/DotLottie/Files/\(name).lottie")
                let container = try Data(contentsOf: input)
                let loaded = container.withUnsafeBytes { bytes in
                    dotlottie_load_dotlottie_data(player, bytes.baseAddress?.assumingMemoryBound(to: CChar.self), UInt(bytes.count))
                }
                guard loaded == Success else {
                    throw ExportError.renderer("Load \(name): \(loaded.rawValue)")
                }
                var duration: Float = 0
                var totalFrames: Float = 0
                guard dotlottie_get_duration(player, &duration) == Success,
                      dotlottie_get_total_frames(player, &totalFrames) == Success,
                      duration > 0, totalFrames > 0 else { throw ExportError.renderer("Animation timing") }
                // The core reports milliseconds; SwiftUI schedules use seconds.
                let seconds = Double(duration) / 1_000
                let count = Int(ceil(seconds * fps))
                guard (1...120).contains(count) else { throw ExportError.renderer("Unexpected frame count: \(count)") }
                counts[name] = count
                durations[name] = seconds
                for index in 0..<count {
                    let frame = Float(index) / Float(count) * (totalFrames - 1)
                    // Loading renders frame zero. ThorVG rejects an unchanged seek;
                    // preserve that first frame instead of requesting it again.
                    if index > 0 {
                        let seekResult = dotlottie_set_frame(player, frame)
                        let renderResult = dotlottie_render(player)
                        guard seekResult == Success, renderResult == Success else {
                            throw ExportError.renderer("Frame \(index): seek=\(seekResult.rawValue), render=\(renderResult.rawValue)")
                        }
                    }
                    guard buffer.contains(where: { $0 != 0 }) else { throw ExportError.renderer("Empty frame \(index)") }
                    let data = Data(bytes: baseAddress, count: size * size * 4)
                    guard let provider = CGDataProvider(data: data as CFData),
                          let image = CGImage(width: size, height: size, bitsPerComponent: 8,
                                              bitsPerPixel: 32, bytesPerRow: size * 4,
                                              space: CGColorSpaceCreateDeviceRGB(),
                                              bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                                              provider: provider, decode: nil,
                                              shouldInterpolate: true, intent: .defaultIntent) else { throw ExportError.renderer("Create image") }
                    let directory = output.appending(path: "watchMood-\(name)-\(index).imageset")
                    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                    let png = directory.appending(path: "frame.png")
                    guard let destination = CGImageDestinationCreateWithURL(png as CFURL, "public.png" as CFString, 1, nil) else {
                        throw ExportError.renderer("PNG destination")
                    }
                    CGImageDestinationAddImage(destination, image, nil)
                    guard CGImageDestinationFinalize(destination) else { throw ExportError.renderer("Write PNG") }
                    let manifest: [String: Any] = [
                        "images": [["filename": "frame.png", "idiom": "universal", "scale": "2x"]],
                        "info": ["author": "xcode", "version": 1]
                    ]
                    try JSONSerialization.data(withJSONObject: manifest, options: [.prettyPrinted, .sortedKeys])
                        .write(to: directory.appending(path: "Contents.json"))
                }
                print("\(name): \(count) frames, \(seconds) seconds")
            }
        }
        let names = ["angry", "sad", "mourn", "wink", "laughing"]
        let countCases = names.map { "        case .\($0): \(counts[$0] ?? 0)" }.joined(separator: "\n")
        let durationCases = names.map { "        case .\($0): \(durations[$0] ?? 0)" }.joined(separator: "\n")
        let source = """
        // Generated by Tools/Assets/ExportWatchMoodFrames.swift from the app's Lottie files.
        enum WatchMoodAnimationFrames {
            static func count(for mood: Mood) -> Int {
                switch mood {
        \(countCases)
                }
            }

            static func duration(for mood: Mood) -> Double {
                switch mood {
        \(durationCases)
                }
            }
        }

        """
        try source.write(to: root.appending(path: "WatchMoodMargins Watch App/WatchMoodAnimationFrames.swift"), atomically: true, encoding: .utf8)
    }
}

private enum ExportError: Error {
    case invalidArguments
    case renderer(String)
}
