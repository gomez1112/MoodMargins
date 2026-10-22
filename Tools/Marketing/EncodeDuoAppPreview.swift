import AppKit
import SwiftUI
import QuartzCore
import AVFoundation
import CoreVideo
import ImageIO
import UniformTypeIdentifiers

// A dependency-free encoder for actual app footage. Apple preview dimensions,
// 30 fps, H.264 High 4.0, and an 11 Mbps target are explicit; UI is never stretched.
let arguments = CommandLine.arguments
guard arguments.count == 6, let width = Int(arguments[3]), let height = Int(arguments[4]) else {
    fatalError("Usage: EncodeDuoAppPreview.swift <source.mp4> <output.mp4> <width> <height> <language>")
}
let language = arguments[5]
let sourceURL = URL(filePath: arguments[1])
let outputURL = URL(filePath: arguments[2])
let asset = AVURLAsset(url: sourceURL)
guard let track = try await asset.loadTracks(withMediaType: .video).first else { fatalError("Missing video track") }
let duration = try await asset.load(.duration)
guard duration.seconds >= 15 else { fatalError("A preview must have at least 15 seconds of app footage") }
let targetFrames = Int(min(duration.seconds, 25) * 30)
let clipDuration = CMTime(value: Int64(targetFrames), timescale: 30)
let naturalSize = try await track.load(.naturalSize)
let preferred = try await track.load(.preferredTransform)
let oriented = CGRect(origin: .zero, size: naturalSize).applying(preferred)
let scale = min(CGFloat(width) / oriented.width, CGFloat(height) / oriented.height)
let transform = preferred
    .concatenating(CGAffineTransform(translationX: -oriented.minX, y: -oriented.minY))
    .concatenating(CGAffineTransform(scaleX: scale, y: scale))
    .concatenating(CGAffineTransform(translationX: (CGFloat(width) - oriented.width * scale) / 2, y: (CGFloat(height) - oriented.height * scale) / 2))
var layer = AVVideoCompositionLayerInstruction.Configuration(assetTrack: track)
layer.setTransform(transform, at: .zero)
let instruction = AVVideoCompositionInstruction(configuration: .init(backgroundColor: CGColor(srgbRed: 0.975, green: 0.945, blue: 0.99, alpha: 1), layerInstructions: [AVVideoCompositionLayerInstruction(configuration: layer)], timeRange: CMTimeRange(start: .zero, duration: duration)))
// Preserve the real framebuffer's aspect ratio. Marketing copy fills the unused
// bands; it never covers or recreates any part of the application's interface.
let captionRenderer = ImageRenderer(content: DuoPreviewCaption(language: language)
    .frame(width: CGFloat(width), height: CGFloat(height)))
captionRenderer.scale = 1
let parentLayer = CALayer()
parentLayer.frame = CGRect(x: 0, y: 0, width: width, height: height)
let videoLayer = CALayer()
videoLayer.frame = parentLayer.bounds
parentLayer.addSublayer(videoLayer)
let captionLayer = CALayer()
captionLayer.frame = parentLayer.bounds
captionLayer.contents = captionRenderer.cgImage
parentLayer.addSublayer(captionLayer)
let animationTool = AVVideoCompositionCoreAnimationTool(configuration: .init(postProcessingAsVideoLayer: videoLayer, containingLayer: parentLayer))
let composition = AVVideoComposition(configuration: .init(animationTool: animationTool, frameDuration: CMTime(value: 1, timescale: 30), instructions: [instruction], renderSize: CGSize(width: width, height: height)))
let reader = try AVAssetReader(asset: asset)
reader.timeRange = CMTimeRange(start: .zero, duration: clipDuration)
let output = AVAssetReaderVideoCompositionOutput(videoTracks: [track], videoSettings: [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA])
output.videoComposition = composition
let provider = reader.outputProvider(for: output)
if FileManager.default.fileExists(atPath: outputURL.path) {
    try FileManager.default.removeItem(at: outputURL)
}
let writer = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
writer.shouldOptimizeForNetworkUse = true
let input = AVAssetWriterInput(mediaType: .video, outputSettings: [
    AVVideoCodecKey: AVVideoCodecType.h264,
    AVVideoWidthKey: width, AVVideoHeightKey: height,
    AVVideoCompressionPropertiesKey: [
        AVVideoAverageBitRateKey: 11_000_000,
        AVVideoProfileLevelKey: AVVideoProfileLevelH264High40,
        AVVideoExpectedSourceFrameRateKey: 30,
        AVVideoMaxKeyFrameIntervalKey: 60
    ]
])
let receiver = writer.inputPixelBufferReceiver(for: input, pixelBufferAttributes: nil)
let silence = AVURLAsset(url: URL(filePath: "/private/tmp/MoodMargins-preview-silence.wav"))
guard let audioTrack = try await silence.loadTracks(withMediaType: .audio).first else { fatalError("Missing silent stereo source") }
let audioReader = try AVAssetReader(asset: silence)
audioReader.timeRange = CMTimeRange(start: .zero, duration: clipDuration)
let audioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: [AVFormatIDKey:kAudioFormatLinearPCM, AVLinearPCMBitDepthKey:16, AVLinearPCMIsFloatKey:false, AVLinearPCMIsNonInterleaved:false])
let audioProvider = audioReader.outputProvider(for: audioOutput)
let audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: [AVFormatIDKey:kAudioFormatMPEG4AAC, AVSampleRateKey:48_000, AVNumberOfChannelsKey:2, AVEncoderBitRateKey:256_000])
let audioReceiver = writer.inputReceiver(for: audioInput)
try writer.start()
writer.startSession(atSourceTime: .zero)
try reader.start()
try audioReader.start()
async let videoEncoding: Int = { @MainActor in
    try await encodeVideo(provider: provider, receiver: receiver, frameCount: targetFrames)
}()
async let audioEncoding: Void = { @MainActor in
    try await encodeAudio(provider: audioProvider, receiver: audioReceiver)
}()
let frames = try await videoEncoding
try await audioEncoding
writer.endSession(atSourceTime: clipDuration)
await writer.finishWriting()
if let error = writer.error { throw error }
let encoded = AVURLAsset(url: outputURL)
let encodedDuration = try await encoded.load(.duration)
guard let video = try await encoded.loadTracks(withMediaType: .video).first else { fatalError("No encoded track") }
let fps = try await video.load(.nominalFrameRate)
let size = try await video.load(.naturalSize)
let bytes = try outputURL.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
guard encodedDuration.seconds >= 15, encodedDuration.seconds <= 30, abs(fps - 30) < 0.01, Int(size.width) == width, Int(size.height) == height, bytes < 500_000_000 else { fatalError("Preview specifications did not pass") }
guard let encodedAudio = try await encoded.loadTracks(withMediaType: .audio).first,
      let format = try await encodedAudio.load(.formatDescriptions).first,
      let audioDescription = CMAudioFormatDescriptionGetStreamBasicDescription(format) else { fatalError("Missing encoded stereo AAC") }
guard audioDescription.pointee.mChannelsPerFrame == 2, audioDescription.pointee.mSampleRate == 48_000, audioDescription.pointee.mFormatID == kAudioFormatMPEG4AAC else { fatalError("Audio specifications did not pass") }
let report: [String: Any] = ["file": outputURL.lastPathComponent, "width": width, "height": height, "durationSeconds": encodedDuration.seconds, "framesPerSecond": fps, "frames": frames, "bytes": bytes, "codec": "H.264", "profile": "High 4.0", "targetBitrate": 11_000_000, "audio": ["codec":"AAC", "sampleRate":48_000, "channels":2, "targetBitrate":256_000, "content":"silence"]]
try JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys]).write(to: outputURL.deletingPathExtension().appendingPathExtension("json"))
let generator = AVAssetImageGenerator(asset: encoded)
generator.appliesPreferredTrackTransform = true
let (poster, _) = try await generator.image(at: CMTime(seconds: 5, preferredTimescale: 600))
if let destination = CGImageDestinationCreateWithURL(outputURL.deletingPathExtension().appendingPathExtension("png") as CFURL, UTType.png.identifier as CFString, 1, nil) {
    CGImageDestinationAddImage(destination, poster, nil)
    guard CGImageDestinationFinalize(destination) else { fatalError("Poster export failed") }
}
print("Encoded \(outputURL.lastPathComponent): \(width)×\(height), \(encodedDuration.seconds)s, \(fps) fps")

// Keep both writer inputs flowing concurrently; the writer applies backpressure
// while interleaving audio and video. Each child is owned by the encoding task.
typealias SampleProvider = AVAssetReaderOutput.Provider<CMReadySampleBuffer<CMSampleBuffer.DynamicContent>>

@MainActor
func encodeAudio(provider: SampleProvider, receiver: AVAssetWriterInput.SampleBufferReceiver) async throws {
    while let sample = try await provider.next() {
        try Task.checkCancellation()
        try await receiver.append(sample)
    }
    receiver.finish()
}

@MainActor
func encodeVideo(provider: SampleProvider, receiver: AVAssetWriterInput.PixelBufferReceiver, frameCount: Int) async throws -> Int {
    var index = 0
    var previous: CVReadOnlyPixelBuffer?
    while let sample = try await provider.next() {
        try Task.checkCancellation()
        guard case .pixelBuffer(let buffer) = sample.content else { continue }
        let boundary = min(frameCount, max(0, Int((sample.presentationTimeStamp.seconds * 30).rounded(.up))))
        if let previous {
            while index < boundary {
                try await receiver.append(previous, with: CMTime(value: Int64(index), timescale: 30))
                index += 1
            }
        }
        previous = buffer
    }
    guard let previous else { fatalError("Source contained no video frames") }
    while index < frameCount {
        try Task.checkCancellation()
        try await receiver.append(previous, with: CMTime(value: Int64(index), timescale: 30))
        index += 1
    }
    receiver.finish()
    return index
}


struct DuoPreviewCaption: View {
    var language: String
    private var headline: String {
        language == "es" ? "Tu diario,\na tu manera." : language == "ar" ? "يومياتك،\nومساحتك الخاصة." : "Your journal,\nyour space."
    }
    private var caption: String {
        language == "es" ? "Elige tu ánimo. Escribe un poco.\nDescubre el ritmo de tus días." : language == "ar" ? "اختر مزاجك واكتب قليلًا.\nواكتشف أنماط أيامك." : "Pick a mood. Write a little.\nFind the patterns in your days."
    }
    var body: some View {
        VStack(spacing: 20) {
            Text("MoodMargins").font(.system(size: 34, weight: .semibold, design: .rounded))
            Text(headline).font(.system(size: 62, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
            Spacer()
            Text(caption).font(.system(size: 33, weight: .medium, design: .rounded))
                .multilineTextAlignment(.center)
            Text("iPhone Duo").font(.system(size: 26, weight: .medium, design: .rounded))
        }
        .foregroundStyle(Color(red: 0.36, green: 0.29, blue: 0.47))
        .padding(.horizontal, 50)
        .padding(.top, 60)
        .padding(.bottom, 90)
        .environment(\.layoutDirection, language == "ar" ? .rightToLeft : .leftToRight)
    }
}
