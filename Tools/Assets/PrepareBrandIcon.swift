import AppKit
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

// Retains generated foreground alpha, resizes for Icon Composer, and supplies
// the same foreground and brand background to visionOS's layered icon.
let arguments = CommandLine.arguments
guard arguments.count == 3 else { fatalError("Usage: PrepareBrandIcon.swift <foreground.png> <project-root>") }
let input = URL(filePath: arguments[1])
let root = URL(filePath: arguments[2], directoryHint: .isDirectory)
guard let source = CGImageSourceCreateWithURL(input as CFURL, nil), let foreground = CGImageSourceCreateImageAtIndex(source, 0, nil) else { fatalError("Cannot open foreground") }
func context() -> CGContext {
    guard let context = CGContext(data: nil, width: 1024, height: 1024, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { fatalError("Cannot create icon canvas") }
    context.interpolationQuality = .high
    return context
}
func write(_ image: CGImage, to url: URL) throws {
    guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else { throw CocoaError(.fileWriteUnknown) }
    CGImageDestinationAddImage(destination, image, nil)
    guard CGImageDestinationFinalize(destination) else { throw CocoaError(.fileWriteUnknown) }
}
let front = context()
front.draw(foreground, in: CGRect(x: 0, y: 0, width: 1024, height: 1024))
guard let notebook = front.makeImage() else { fatalError("Cannot render notebook") }
try write(notebook, to: root.appending(path: "MoodMarginsIcon.icon/Assets/Notebook.png"))
let vision = root.appending(path: "MoodMargins/Assets.xcassets/VisionAppIcon.solidimagestack")
let back = context()
guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [CGColor(red: 1, green: 0.88, blue: 0.93, alpha: 1), CGColor(red: 0.86, green: 0.84, blue: 1, alpha: 1)] as CFArray, locations: [0, 1]) else { fatalError("Cannot render brand gradient") }
back.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 1024), end: CGPoint(x: 1024, y: 0), options: [])
guard let background = back.makeImage(), let middle = context().makeImage() else { fatalError("Cannot render icon layers") }
try write(background, to: vision.appending(path: "Back.solidimagestacklayer/Content.imageset/Artwork.png"))
try write(middle, to: vision.appending(path: "Middle.solidimagestacklayer/Content.imageset/Artwork.png"))
let visionFront = context()
visionFront.draw(notebook, in: CGRect(x: 82, y: 82, width: 860, height: 860))
guard let visionNotebook = visionFront.makeImage() else { fatalError("Cannot render spatial notebook") }
try write(visionNotebook, to: vision.appending(path: "Front.solidimagestacklayer/Content.imageset/Artwork.png"))
let preview = context()
preview.draw(background, in: CGRect(x: 0, y: 0, width: 1024, height: 1024))
preview.draw(notebook, in: CGRect(x: 0, y: 0, width: 1024, height: 1024))
if let image = preview.makeImage() { try write(image, to: root.appending(path: "Marketing/IconPreview.png")) }
