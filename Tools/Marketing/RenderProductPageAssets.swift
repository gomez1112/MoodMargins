import AppKit
import SwiftUI
import ImageIO
import UniformTypeIdentifiers

// These exports are marketing artwork, not app UI or fabricated device captures.
struct CampaignCopy {
    var language: String
    var locale: String
    var header: String
    var search: String
    var promotionalText: String
    var headlines: [String]
    var captions: [String]

    var isRTL: Bool { language == "ar" }
}

let copies = [
    CampaignCopy(language: "en", locale: "en-US", header: "Room for\nevery feeling.", search: "Your daily\nmood journal.",
                 promotionalText: "Start with one mood and a few words. Your pages save automatically. Explore mood trends, your most common mood, and your longest journaling streak.",
                 headlines: ["One mood.\nA moment for you.", "Your mood,\nin perspective.", "Write a little.\nKeep your day."],
                 captions: ["A quick check-in, on your terms.", "Trends, common moods, and streaks.", "Your pages save automatically."]),
    CampaignCopy(language: "es", locale: "es-ES", header: "Espacio para\ncada emoción.", search: "Tu diario\nde ánimo.",
                 promotionalText: "Empieza con un ánimo y unas palabras. Tus páginas se guardan automáticamente. Descubre tendencias, tu ánimo más frecuente y tu racha más larga.",
                 headlines: ["Un ánimo.\nUn momento para ti.", "Tu ánimo,\nen perspectiva.", "Escribe un poco.\nRecuerda tu día."],
                 captions: ["Una pausa a tu manera.", "Tendencias, emociones y rachas.", "Tus páginas se guardan automáticamente."]),
    CampaignCopy(language: "ar", locale: "ar-SA", header: "مساحة لكل\nمشاعرك.", search: "يوميات\nلمشاعرك.",
                 promotionalText: "ابدأ بشعور واحد وبضع كلمات. تُحفظ صفحاتك تلقائيًا. اكتشف اتجاهات مزاجك وشعورك الأكثر شيوعًا وأطول سلسلة تدوين لديك.",
                 headlines: ["شعور واحد.\nلحظة لك.", "مزاجك،\nبصورة أوضح.", "اكتب قليلًا.\nواحتفظ بيومك."],
                 captions: ["لحظة تأمل بطريقتك.", "اتجاهات المشاعر وسلاسل التدوين.", "تُحفظ صفحاتك تلقائيًا."])
]

enum AssetKind: String, CaseIterable {
    case header
    case search

    var pixels: CGSize {
        switch self {
        case .header: CGSize(width: 3840, height: 1646)
        case .search: CGSize(width: 3840, height: 2560)
        }
    }

    // Bounds read from Apple's 2026 Photoshop template's “Art Safe Area” layer.
    var safeArea: CGRect {
        switch self {
        case .header: CGRect(x: 1097, y: 493, width: 1646, height: 661)
        case .search: CGRect(x: 836, y: 765, width: 2168, height: 1030)
        }
    }
}

let ink = Color(red: 0.38, green: 0.32, blue: 0.49)
let paper = Color(red: 0.99, green: 0.97, blue: 0.93)
let blush = Color(red: 1, green: 0.86, blue: 0.91)
let lavender = Color(red: 0.87, green: 0.85, blue: 0.99)
let sky = Color(red: 0.80, green: 0.94, blue: 0.96)

enum ExportError: Error {
    case image(String)
    case rendering
    case write(String)
}

func loadImage(_ path: String) throws -> CGImage {
    guard let source = CGImageSourceCreateWithURL(URL(filePath: path) as CFURL, nil),
          let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
        throw ExportError.image(path)
    }
    return image
}

struct CreativeBackdrop: View {
    var canvas: CGSize

    var body: some View {
        ZStack {
            LinearGradient(colors: [blush, Color(red: 0.97, green: 0.92, blue: 0.98), lavender],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            Ellipse().fill(.white.opacity(0.28))
                .frame(width: canvas.width * 0.85, height: canvas.height * 1.6)
                .rotationEffect(.degrees(-12))
                .position(x: canvas.width * 0.08, y: canvas.height * 0.2)
            Ellipse().fill(sky.opacity(0.26))
                .frame(width: canvas.width * 0.6, height: canvas.height * 1.3)
                .position(x: canvas.width * 0.93, y: canvas.height * 1.03)
            RoundedRectangle(cornerRadius: 80)
                .stroke(ink.opacity(0.08), lineWidth: 4)
                .frame(width: canvas.width * 0.89, height: canvas.height * 0.83)
                .rotationEffect(.degrees(-6))
                .position(x: canvas.width * 0.52, y: canvas.height * 0.7)
            RoundedRectangle(cornerRadius: 80)
                .stroke(.white.opacity(0.38), lineWidth: 4)
                .frame(width: canvas.width * 0.9, height: canvas.height * 0.83)
                .rotationEffect(.degrees(7))
                .position(x: canvas.width * 0.43, y: canvas.height * 0.23)
        }
        .frame(width: canvas.width, height: canvas.height)
        .clipped()
    }
}

struct CreativeArtwork: View {
    var kind: AssetKind
    var copy: CampaignCopy
    var notebook: CGImage
    var capture: CGImage

    var body: some View {
        ZStack(alignment: .topLeading) {
            CreativeBackdrop(canvas: kind.pixels)
            if kind == .header {
                headerComposition
            } else {
                searchComposition
            }
        }
        .frame(width: kind.pixels.width, height: kind.pixels.height)
        .clipped()
    }

    private var headerComposition: some View {
        let textX: CGFloat = copy.isRTL ? 2210 : 1650
        let bookX: CGFloat = copy.isRTL ? 1400 : 2440
        return ZStack {
            Text(copy.header)
                .font(.system(size: copy.language == "es" ? 94 : 108, weight: .bold, design: .rounded))
                .tracking(copy.isRTL ? 0 : -3)
                .foregroundStyle(ink)
                .multilineTextAlignment(copy.isRTL ? .trailing : .leading)
                .environment(\.layoutDirection, copy.isRTL ? .rightToLeft : .leftToRight)
                .frame(width: 910, alignment: copy.isRTL ? .trailing : .leading)
                .fixedSize(horizontal: false, vertical: true)
                .position(x: textX, y: 817)
            Image(decorative: notebook, scale: 1).resizable().aspectRatio(contentMode: .fit)
                .frame(height: 546)
                .rotationEffect(.degrees(copy.isRTL ? 7 : -7))
                .shadow(color: ink.opacity(0.14), radius: 24, x: 8, y: 18)
                .position(x: bookX, y: 815)
        }
        .frame(width: kind.pixels.width, height: kind.pixels.height)
    }

    private var searchComposition: some View {
        let textX: CGFloat = copy.isRTL ? 2510 : 1320
        let captureX: CGFloat = copy.isRTL ? 1310 : 2520
        return ZStack {
            Text(copy.search)
                .font(.system(size: copy.isRTL ? 158 : 138, weight: .bold, design: .rounded))
                .tracking(copy.isRTL ? 0 : -4)
                .foregroundStyle(ink)
                .multilineTextAlignment(copy.isRTL ? .trailing : .leading)
                .environment(\.layoutDirection, copy.isRTL ? .rightToLeft : .leftToRight)
                .frame(width: 880, alignment: copy.isRTL ? .trailing : .leading)
                .fixedSize(horizontal: false, vertical: true)
                .position(x: textX, y: 1245)
            Image(decorative: capture, scale: 1).resizable().aspectRatio(contentMode: .fit)
                .frame(width: 760)
                .clipShape(.rect(cornerRadius: 38))
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 48).fill(paper)
                        .overlay { RoundedRectangle(cornerRadius: 48).stroke(.white.opacity(0.9), lineWidth: 4) }
                }
                .shadow(color: ink.opacity(0.18), radius: 28, x: 0, y: 24)
                .position(x: captureX, y: 1280)
        }
        .frame(width: kind.pixels.width, height: kind.pixels.height)
    }
}

struct CheckInScreenshot: View {
    var copy: CampaignCopy
    var index: Int
    var device: String
    var capture: CGImage
    var canvas: CGSize

    private var tablet: Bool { device == "ipad" }
    private var accent: Color { index == 0 ? blush : index == 1 ? sky : lavender }

    var body: some View {
        ZStack(alignment: .topLeading) {
            accent
            Ellipse().fill(.white.opacity(0.23))
                .frame(width: canvas.width * 1.5, height: canvas.height * 0.85)
                .position(x: canvas.width * 0.83, y: canvas.height * 0.82)
            VStack(alignment: copy.isRTL ? .trailing : .leading, spacing: tablet ? 27 : 22) {
                Text("MoodMargins").font(.system(size: tablet ? 45 : 38, weight: .semibold, design: .rounded))
                Text(copy.headlines[index])
                    .font(.system(size: tablet ? 140 : 118, weight: .bold, design: .rounded))
                    .tracking(copy.isRTL ? 0 : -4)
                    .fixedSize(horizontal: false, vertical: true)
                Text(copy.captions[index])
                    .font(.system(size: tablet ? 49 : 42, weight: .medium))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundStyle(ink)
            .multilineTextAlignment(copy.isRTL ? .trailing : .leading)
            .environment(\.layoutDirection, copy.isRTL ? .rightToLeft : .leftToRight)
            .frame(width: canvas.width - (tablet ? 208 : 160), alignment: copy.isRTL ? .trailing : .leading)
            .offset(x: tablet ? 104 : 80, y: tablet ? 70 : 60)

            let width: CGFloat = tablet ? 1530 : 1010
            let bezel: CGFloat = tablet ? 20 : 14
            let radius: CGFloat = tablet ? 54 : 78
            let screenHeight = width * CGFloat(capture.height) / CGFloat(capture.width)
            Image(decorative: capture, scale: 1).resizable().interpolation(.high)
                .frame(width: width, height: screenHeight)
                .clipShape(.rect(cornerRadius: radius - bezel))
                .padding(bezel)
                .background {
                    RoundedRectangle(cornerRadius: radius).fill(ink.opacity(0.95))
                        .overlay { RoundedRectangle(cornerRadius: radius).stroke(.white.opacity(0.65), lineWidth: 3) }
                }
                .shadow(color: ink.opacity(0.22), radius: 25, x: 0, y: 18)
                .position(x: canvas.width / 2, y: (tablet ? 650 : 590) + (screenHeight + bezel * 2) / 2)
        }
        .frame(width: canvas.width, height: canvas.height)
        .clipped()
    }
}

func export<V: View>(_ view: V, to path: String) throws -> CGImage {
    let renderer = ImageRenderer(content: view)
    renderer.scale = 1
    guard let rendered = renderer.cgImage,
          let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
          let context = CGContext(data: nil, width: rendered.width, height: rendered.height,
                                  bitsPerComponent: 8, bytesPerRow: rendered.width * 4,
                                  space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else {
        throw ExportError.rendering
    }
    context.setFillColor(NSColor.white.cgColor)
    context.fill(CGRect(x: 0, y: 0, width: rendered.width, height: rendered.height))
    context.draw(rendered, in: CGRect(x: 0, y: 0, width: rendered.width, height: rendered.height))
    guard let result = context.makeImage(),
          let destination = CGImageDestinationCreateWithURL(URL(filePath: path) as CFURL, UTType.png.identifier as CFString, 1, nil) else {
        throw ExportError.write(path)
    }
    CGImageDestinationAddImage(destination, result, [kCGImagePropertyPNGDictionary: [kCGImagePropertyPNGInterlaceType: 0]] as CFDictionary)
    guard CGImageDestinationFinalize(destination) else { throw ExportError.write(path) }
    return result
}

func save(_ image: CGImage, to path: String) throws {
    guard let destination = CGImageDestinationCreateWithURL(URL(filePath: path) as CFURL, UTType.png.identifier as CFString, 1, nil) else {
        throw ExportError.write(path)
    }
    CGImageDestinationAddImage(destination, image, nil)
    guard CGImageDestinationFinalize(destination) else { throw ExportError.write(path) }
}

let root = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "."
let output = "\(root)/Marketing/ProductPage"
try FileManager.default.createDirectory(atPath: output, withIntermediateDirectories: true)
let book = try loadImage("\(root)/MoodMarginsIcon.icon/Assets/Notebook.png")
guard let notebook = book.cropping(to: CGRect(x: 183, y: 106, width: 670, height: 814)) else {
    throw ExportError.image("Notebook crop")
}
for copy in copies {
    let folder = "\(output)/\(copy.locale)"
    try FileManager.default.createDirectory(atPath: "\(folder)/Review", withIntermediateDirectories: true)
    let today = try loadImage("\(root)/Marketing/SourceCaptures/\(copy.language)/iphone-today.png")
    // An unaltered crop of the real Today screen: mood controls plus the saved journal page.
    guard let crop = today.cropping(to: CGRect(x: 40, y: 205, width: 1126, height: 1320)) else {
        throw ExportError.image("Today crop")
    }
    for kind in AssetKind.allCases {
        let image = try export(CreativeArtwork(kind: kind, copy: copy, notebook: notebook, capture: crop),
                               to: "\(folder)/\(kind.rawValue).png")
        guard let safe = image.cropping(to: kind.safeArea) else { throw ExportError.rendering }
        try save(safe, to: "\(folder)/Review/\(kind.rawValue)-safe-area.png")
    }
    for device in ["iphone", "ipad"] {
        let canvas = device == "iphone" ? CGSize(width: 1320, height: 2868) : CGSize(width: 2064, height: 2752)
        try FileManager.default.createDirectory(atPath: "\(folder)/\(device)", withIntermediateDirectories: true)
        for (index, source) in ["today", "insights", "pages"].enumerated() {
            let capture = try loadImage("\(root)/Marketing/SourceCaptures/\(copy.language)/\(device)-\(source).png")
            _ = try export(CheckInScreenshot(copy: copy, index: index, device: device, capture: capture, canvas: canvas),
                           to: "\(folder)/\(device)/0\(index + 1)-\(source).png")
        }
    }
    print("Exported \(copy.locale): header, search artwork, safe-area previews, and six custom-page screenshots.")
}
