import AppKit
import ImageIO

let root = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "Marketing/ProductPage"
let size = NSSize(width: 2400, height: 2040)
guard let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size.width), pixelsHigh: Int(size.height),
                                   bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                                   colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0),
      let context = NSGraphicsContext(bitmapImageRep: bitmap) else { fatalError("Cannot create artwork sheet") }
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = context
NSColor(red: 0.99, green: 0.98, blue: 0.96, alpha: 1).setFill()
NSRect(origin: .zero, size: size).fill()

func label(_ value: String, x: CGFloat, top: CGFloat, size: CGFloat = 26) {
    (value as NSString).draw(at: NSPoint(x: x, y: 2040 - top - size * 1.3),
                            withAttributes: [.font: NSFont.systemFont(ofSize: size, weight: .semibold),
                                             .foregroundColor: NSColor(red: 0.38, green: 0.32, blue: 0.49, alpha: 1)])
}
func image(_ file: String, x: CGFloat, top: CGFloat, width: CGFloat, maxHeight: CGFloat) throws {
    let url = URL(filePath: "\(root)/\(file)")
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
          let cg = CGImageSourceCreateImageAtIndex(source, 0, nil) else { fatalError("Missing \(file)") }
    let scale = min(width / CGFloat(cg.width), maxHeight / CGFloat(cg.height))
    let w = CGFloat(cg.width) * scale
    let h = CGFloat(cg.height) * scale
    let rect = NSRect(x: x + (width - w) / 2, y: 2040 - top - h, width: w, height: h)
    NSImage(cgImage: cg, size: rect.size).draw(in: rect)
}
label("MoodMargins · Daily check-ins", x: 48, top: 26, size: 42)
label("Creative assets show Apple’s focal safe-area crop; full-size exports are separate.", x: 48, top: 86, size: 24)
for (column, locale) in ["en-US", "es-ES", "ar-SA"].enumerated() {
    let x = CGFloat(column) * 800 + 40
    label(locale, x: x, top: 140, size: 30)
    label("Header · safe-area preview", x: x, top: 186)
    try image("\(locale)/Review/header-safe-area.png", x: x, top: 230, width: 720, maxHeight: 300)
    label("Search · safe-area preview", x: x, top: 550)
    try image("\(locale)/Review/search-safe-area.png", x: x, top: 595, width: 720, maxHeight: 350)
    label("iPhone · check in → Insights → pages", x: x, top: 968, size: 24)
    for (index, name) in ["01-today", "02-insights", "03-pages"].enumerated() {
        try image("\(locale)/iphone/\(name).png", x: x + CGFloat(index) * 245, top: 1015, width: 232, maxHeight: 515)
    }
    label("iPad · same story, native interface", x: x, top: 1548, size: 24)
    for (index, name) in ["01-today", "02-insights", "03-pages"].enumerated() {
        try image("\(locale)/ipad/\(name).png", x: x + CGFloat(index) * 245, top: 1595, width: 232, maxHeight: 350)
    }
}
NSGraphicsContext.restoreGraphicsState()
guard let data = bitmap.representation(using: .png, properties: [:]) else { fatalError("Cannot export artwork sheet") }
try data.write(to: URL(filePath: "\(root)/ContactSheet.png"))
print("\(root)/ContactSheet.png")
