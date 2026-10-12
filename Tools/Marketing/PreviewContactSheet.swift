import AppKit
import AVFoundation
import ImageIO
import UniformTypeIdentifiers

let directory = URL(filePath: CommandLine.arguments[1])
let output = URL(filePath: CommandLine.arguments[2])
let canvas = NSSize(width: 1200, height: 2700)
let sheet = NSImage(size: canvas)
sheet.lockFocus()
NSColor.white.setFill()
NSRect(origin: .zero, size: canvas).fill()
sheet.unlockFocus()
for (row, pair) in [("en", "iphone"), ("en", "ipad"), ("en", "mac"), ("es", "iphone"), ("es", "ipad"), ("es", "mac"), ("ar", "iphone"), ("ar", "ipad"), ("ar", "mac")].enumerated() {
    let asset = AVURLAsset(url: directory.appending(path: "\(pair.0)/\(pair.1).mp4"))
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    for (column, second) in [3, 8, 13, 17].enumerated() {
        let (frame, _) = try await generator.image(at: CMTime(seconds: Double(second), preferredTimescale: 600))
        let scale = min(290.0 / Double(frame.width), 266.0 / Double(frame.height))
        let size = NSSize(width: Double(frame.width) * scale, height: Double(frame.height) * scale)
        let rect = NSRect(x: Double(column) * 300 + (300 - size.width) / 2, y: 2700 - Double(row + 1) * 300 + 10, width: size.width, height: size.height)
        sheet.lockFocus()
        NSImage(cgImage: frame, size: size).draw(in: rect)
        let label = "\(pair.0) · \(pair.1) · \(second)s"
        (label as NSString).draw(at: NSPoint(x: Double(column) * 300 + 12, y: 2700 - Double(row + 1) * 300 + 282), withAttributes: [.font:NSFont.systemFont(ofSize:12), .foregroundColor:NSColor.black])
        sheet.unlockFocus()
    }
}
guard let data = sheet.tiffRepresentation, let bitmap = NSBitmapImageRep(data: data), let png = bitmap.representation(using: .png, properties: [:]) else { fatalError("Contact sheet export failed") }
try png.write(to: output)
print(output.lastPathComponent)
