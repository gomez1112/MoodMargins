import AppKit
import ImageIO

let arguments = CommandLine.arguments
guard arguments.count == 4 else { fatalError("Usage: ScreenshotContactSheet.swift <rendered-directory> <language> <output.png>") }
let root = URL(filePath: arguments[1]).appending(path: arguments[2])
let size = NSSize(width: 2400, height: 2400)
guard let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size.width), pixelsHigh: Int(size.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0),
      let context = NSGraphicsContext(bitmapImageRep: bitmap) else { fatalError("Cannot create contact sheet") }
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = context
NSColor.white.setFill()
NSRect(origin: .zero, size: size).fill()
for (row, device) in ["iphone", "ipad", "mac", "watch", "vision"].enumerated() {
    let directory = root.appending(path: device)
    let files = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        .filter { $0.pathExtension == "png" }.sorted { $0.lastPathComponent < $1.lastPathComponent }
    let bottom = size.height - Double(row + 1) * 480
    ("\(arguments[2].uppercased()) · \(device) · \(files.count) screenshots" as NSString).draw(
        at: NSPoint(x: 24, y: bottom + 450),
        withAttributes: [.font: NSFont.systemFont(ofSize: 20, weight: .semibold), .foregroundColor: NSColor.black]
    )
    for (column, url) in files.enumerated() {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil), let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else { fatalError("Missing \(url.path)") }
        let scale = min(376 / Double(image.width), 418 / Double(image.height))
        let width = Double(image.width) * scale
        let height = Double(image.height) * scale
        let rect = NSRect(x: Double(column) * 400 + (400 - width) / 2, y: bottom + (438 - height) / 2, width: width, height: height)
        NSImage(cgImage: image, size: rect.size).draw(in: rect)
    }
}
NSGraphicsContext.restoreGraphicsState()
guard let png = bitmap.representation(using: .png, properties: [:]) else { fatalError("Cannot export contact sheet") }
try png.write(to: URL(filePath: arguments[3]))
print(arguments[3])
