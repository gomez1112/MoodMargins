import AppKit
import SwiftUI
import ImageIO
import UniformTypeIdentifiers

struct Slide {
    var file: String
    var headline: String
    var subtitle: String
    var color: Color
    var source: String
    var angle: Double
}

let englishSlides: [Slide] = [
    Slide(file: "01-every-feeling", headline: "Room for\nevery feeling.", subtitle: "Your daily mood journal.", color: Color(red: 1, green: 0.83, blue: 0.89), source: "today", angle: -3),
    Slide(file: "02-autosave", headline: "Write a little.\nKeep the moment.", subtitle: "Your pages save automatically.", color: Color(red: 0.89, green: 0.86, blue: 1), source: "pages", angle: 3),
    Slide(file: "03-mood-trends", headline: "See the shape\nof your days.", subtitle: "Emoji charts. Clearer patterns.", color: Color(red: 0.79, green: 0.94, blue: 0.96), source: "insights", angle: -2),
    Slide(file: "04-mood-stickers", headline: "Every mood\nhas a place.", subtitle: "Look back with expressive stickers.", color: Color(red: 1, green: 0.90, blue: 0.76), source: "insights", angle: 3),
    Slide(file: "05-premium-themes", headline: "A notebook\nthat feels like you.", subtitle: "Three premium palettes. Your choice.", color: Color(red: 0.87, green: 0.94, blue: 0.83), source: "themes", angle: 0),
    Slide(file: "06-dark-appearance", headline: "A quieter view.\nDay or night.", subtitle: "Thoughtful light and dark appearances.", color: Color(red: 0.18, green: 0.16, blue: 0.25), source: "dark", angle: -3)
]

let spanishCopy: [(String, String)] = [
    ("Espacio para\ncada emoción.", "Tu diario de ánimo, cada día."),
    ("Escribe un poco.\nRecuerda tu día.", "Tus páginas se guardan automáticamente."),
    ("Descubre el ritmo\nde tus días.", "Gráficas con emojis. Patrones más claros."),
    ("Cada emoción\ntiene su lugar.", "Mira atrás con stickers expresivos."),
    ("Un cuaderno\nque va contigo.", "Tres paletas premium. Tú eliges."),
    ("Una vista serena.\nDe día y de noche.", "Apariencias clara y oscura cuidadas.")
]
let arabicCopy: [(String, String)] = [
    ("مساحة لكل\nمشاعرك.", "يوميات مزاجك، يومًا بيوم."),
    ("اكتب قليلًا.\nواحتفظ باللحظة.", "تُحفظ صفحاتك تلقائيًا."),
    ("اكتشف إيقاع\nأيامك.", "رسوم بالوجوه التعبيرية وأنماط أوضح."),
    ("لكل شعور\nمكانه.", "تأمل أيامك بملصقات معبّرة."),
    ("دفتر يشبهك\nويعبّر عنك.", "ثلاث لوحات ألوان مميزة. الخيار لك."),
    ("إطلالة هادئة.\nليلًا ونهارًا.", "مظهران فاتح وداكن بعناية.")
]
func slides(for language: String) -> [Slide] {
    englishSlides.enumerated().map { index, original in
        var slide = original
        if language == "es" { (slide.headline, slide.subtitle) = spanishCopy[index] }
        if language == "ar" { (slide.headline, slide.subtitle) = arabicCopy[index] }
        if index == 3 { slide.source = "stickers" }
        return slide
    }
}

struct ScreenshotArtwork: View {
    var slide: Slide
    var language: String
    var device: String
    var captureDirectory: URL
    var canvas: CGSize
    private var rtl: Bool { language == "ar" }
    private var themeFooter: String { language == "es" ? "Con Plus o una compra única del tema." : language == "ar" ? "مع Plus أو بشراء السمة مرة واحدة." : "Plus or a one-time theme purchase." }
    private var dark: Bool { slide.source == "dark" }
    private var ink: Color { dark ? Color(red: 0.95, green: 0.92, blue: 1) : Color(red: 0.23, green: 0.21, blue: 0.32) }
    private var scale: CGFloat { canvas.width / 440 }
    private var wide: Bool { device == "mac" }
    private var tablet: Bool { device == "ipad" }

    var body: some View {
        ZStack(alignment: .topLeading) {
            slide.color.overlay(alignment: .topLeading) {
                ZStack(alignment: .topLeading) {
                    Circle().fill(.white.opacity(dark ? 0.035 : 0.22))
                        .frame(width: canvas.width * 1.15, height: canvas.width * 1.15)
                        .offset(x: canvas.width * 0.18, y: canvas.height * 0.48)
                    RoundedRectangle(cornerRadius: 28 * scale).stroke(ink.opacity(0.09), lineWidth: scale)
                        .frame(width: canvas.width * 1.2, height: canvas.height * 0.70)
                        .rotationEffect(.degrees(-14))
                        .offset(x: -canvas.width * 0.35, y: canvas.height * 0.49)
                }
                .frame(width: canvas.width, height: canvas.height, alignment: .topLeading)
                .clipped()
            }
            branding
                .frame(width: canvas.width - 56 * scale, alignment: rtl ? .trailing : .leading)
                .offset(x: 28 * scale, y: wide ? canvas.height * 0.065 : 40 * scale)
            if wide { desktopComposition }
            else if tablet { tabletComposition }
            else { phoneComposition }
        }
        .frame(width: canvas.width, height: canvas.height)
        .clipped()
    }

    private var branding: some View {
        HStack(spacing: 8 * scale) {
            Image(systemName: "book.pages.fill").font(.system(size: 17 * scale, weight: .semibold))
            Text("MoodMargins").font(.system(size: 15 * scale, weight: .bold, design: .rounded))
        }
        .foregroundStyle(ink)
    }

    private func heading(font: CGFloat, width: CGFloat) -> some View {
        VStack(alignment: rtl ? .trailing : .leading, spacing: 12 * scale) {
            Text(slide.headline)
                .font(.system(size: font, weight: .heavy, design: .rounded))
                .tracking(rtl ? 0 : -font * 0.035)
                .lineSpacing(-font * 0.03)
                .fixedSize(horizontal: false, vertical: true)
            Text(slide.subtitle).font(.system(size: wide ? canvas.width * 0.024 : 16 * scale, weight: .medium))
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(ink)
        .multilineTextAlignment(rtl ? .trailing : .leading)
        .environment(\.layoutDirection, rtl ? .rightToLeft : .leftToRight)
        .frame(width: width, alignment: rtl ? .trailing : .leading)
    }

    private var phoneComposition: some View {
        ZStack(alignment: .topLeading) {
            heading(font: 45, width: 386).offset(x: 28, y: 98)
            if slide.source == "themes" {
                themeStack(width: 270, spacing: 220).offset(x: 85, y: 272)
                Text(themeFooter)
                    .font(.system(size: 15, weight: .semibold)).foregroundStyle(ink)
                    .frame(width: 400).position(x: 220, y: 934)
            } else {
                deviceFrame(source: slide.source, width: 326, bezel: 8, radius: 43)
                    .rotationEffect(.degrees(slide.angle))
                    .position(x: 220, y: 606)

            }
        }
        .frame(width: canvas.width, height: canvas.height, alignment: .topLeading)
    }

    private var tabletComposition: some View {
        ZStack(alignment: .topLeading) {
            heading(font: 45 * scale, width: canvas.width - 56 * scale)
                .offset(x: 28 * scale, y: 83 * scale)
            if slide.source == "themes" {
                themeGrid.offset(x: canvas.width * 0.065, y: canvas.height * 0.40)
                Text(themeFooter)
                    .font(.system(size: 15 * scale, weight: .semibold)).foregroundStyle(ink)
                    .position(x: canvas.width / 2, y: canvas.height * 0.95)
            } else {
                deviceFrame(source: slide.source, width: canvas.width * 0.76, bezel: 9 * scale, radius: 26 * scale)
                    .rotationEffect(.degrees(slide.angle * 0.5))
                    .position(x: canvas.width / 2, y: canvas.height * 0.80)
            }
        }
        .frame(width: canvas.width, height: canvas.height, alignment: .topLeading)
    }

    private var themeGrid: some View {
        let width = canvas.width * 0.41
        return ZStack(alignment: .topLeading) {
            ForEach(["botanical", "coastal", "sunset"].enumerated(), id: \.element) { index, theme in
                let image = load(theme, forceDevice: "ipad")
                let rect = CGRect(x: CGFloat(image.width) * 0.1938, y: CGFloat(image.height) * 0.1977, width: CGFloat(image.width) * 0.6124, height: CGFloat(image.height) * 0.2805)
                let preview = image.cropping(to: rect) ?? image
                VStack(alignment: rtl ? .trailing : .leading, spacing: 8 * scale) {
                    Text(themeName(theme)).font(.system(size: 17 * scale, weight: .bold, design: .rounded)).foregroundStyle(ink)
                    Image(decorative: preview, scale: 1).resizable().frame(width: width, height: width * CGFloat(preview.height) / CGFloat(preview.width))
                        .clipShape(.rect(cornerRadius: 16 * scale)).shadow(color: .black.opacity(0.12), radius: 8 * scale, y: 6 * scale)
                }
                .rotationEffect(.degrees(index == 0 ? -3 : 3))
                .offset(x: index == 1 ? canvas.width * 0.46 : index == 2 ? canvas.width * 0.23 : 0, y: index == 2 ? canvas.height * 0.26 : 0)
            }
        }
        .frame(width: canvas.width * 0.87, height: canvas.height * 0.51, alignment: .topLeading)
    }

    private var desktopComposition: some View {
        ZStack(alignment: .topLeading) {
            heading(font: canvas.width * 0.050, width: canvas.width * 0.38)
                .offset(x: canvas.width * 0.045, y: canvas.height * 0.24)
            if slide.source == "themes" {
                desktopThemeGrid
                    .offset(x: canvas.width * 0.49, y: canvas.height * 0.20)
                Text(themeFooter)
                    .font(.system(size: canvas.width * 0.015, weight: .semibold)).foregroundStyle(ink)
                    .position(x: canvas.width * 0.24, y: canvas.height * 0.80)
            } else {
                deviceFrame(source: slide.source, width: canvas.width * 0.54, bezel: canvas.width * 0.004, radius: canvas.width * 0.012)
                    .rotationEffect(.degrees(slide.angle * 0.35))
                    .position(x: canvas.width * 0.72, y: canvas.height * 0.54)
            }
        }
    }

    private var desktopThemeGrid: some View {
        let width = canvas.width * 0.225
        return ZStack(alignment: .topLeading) {
            ForEach(["botanical", "coastal", "sunset"].enumerated(), id: \.element) { index, theme in
                let image = load(theme, forceDevice: "ipad")
                let rect = CGRect(x: CGFloat(image.width) * 0.1938, y: CGFloat(image.height) * 0.1977, width: CGFloat(image.width) * 0.6124, height: CGFloat(image.height) * 0.2805)
                let preview = image.cropping(to: rect) ?? image
                VStack(alignment: rtl ? .trailing : .leading, spacing: 8) {
                    Text(themeName(theme)).font(.system(size: 20, weight: .bold, design: .rounded)).foregroundStyle(ink)
                    Image(decorative: preview, scale: 1).resizable().frame(width: width, height: width * CGFloat(preview.height) / CGFloat(preview.width))
                        .clipShape(.rect(cornerRadius: 12)).shadow(color: .black.opacity(0.12), radius: 8, y: 6)
                }
                .rotationEffect(.degrees(index == 0 ? -3 : 3))
                .offset(x: index == 1 ? canvas.width * 0.245 : index == 2 ? canvas.width * 0.1225 : 0, y: index == 2 ? canvas.height * 0.34 : 0)
            }
        }
        .frame(width: canvas.width * 0.49, height: canvas.height * 0.64, alignment: .topLeading)
    }

    private func deviceFrame(source: String, width: CGFloat, bezel: CGFloat, radius: CGFloat) -> some View {
        let image = load(source)
        let screenWidth = width - 2 * bezel
        let height = screenWidth * CGFloat(image.height) / CGFloat(image.width)
        return Image(decorative: image, scale: 1)
            .resizable().interpolation(.high)
            .frame(width: screenWidth, height: height)
            .clipShape(.rect(cornerRadius: max(radius - bezel, 0)))
            .padding(bezel)
            .background {
                RoundedRectangle(cornerRadius: radius)
                    .fill(Color(red: 0.13, green: 0.14, blue: 0.17))
                    .overlay { RoundedRectangle(cornerRadius: radius).stroke(.white.opacity(0.35), lineWidth: 1) }
            }
            .shadow(color: .black.opacity(dark ? 0.40 : 0.20), radius: bezel * 2.2, x: bezel * 0.4, y: bezel * 2)
    }

    private func themeStack(width: CGFloat, spacing: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            ForEach(["botanical", "coastal", "sunset"].enumerated(), id: \.element) { index, theme in
                let image = load(theme, forceDevice: "ipad")
                // Crop the actual theme preview, excluding unloaded StoreKit catalog controls.
                let rect = CGRect(x: CGFloat(image.width) * 0.1938, y: CGFloat(image.height) * 0.1977, width: CGFloat(image.width) * 0.6124, height: CGFloat(image.height) * 0.2805)
                let preview = image.cropping(to: rect) ?? image
                VStack(alignment: rtl ? .trailing : .leading, spacing: 7 * scale) {
                    Text(themeName(theme)).font(.system(size: 16 * scale, weight: .bold, design: .rounded)).foregroundStyle(ink)
                    Image(decorative: preview, scale: 1).resizable().interpolation(.high)
                        .frame(width: width, height: width * CGFloat(preview.height) / CGFloat(preview.width))
                        .clipShape(.rect(cornerRadius: 16 * scale))
                        .overlay { RoundedRectangle(cornerRadius: 16 * scale).stroke(.white.opacity(0.65), lineWidth: 1 * scale) }
                        .shadow(color: .black.opacity(0.13), radius: 10 * scale, y: 6 * scale)
                }
                .rotationEffect(.degrees([Double(-5), 3, -2][index]))
                .offset(x: index == 1 ? -12 * scale : 0, y: CGFloat(index) * spacing)
            }
        }
        .frame(width: width, height: spacing * 2 + width * 0.62, alignment: .topLeading)
    }

    private func themeName(_ theme: String) -> String {
        let names = language == "es" ? ["botanical": "Botánica", "coastal": "Costera", "sunset": "Atardecer"] : language == "ar" ? ["botanical": "نباتية", "coastal": "ساحلية", "sunset": "الغروب"] : ["botanical": "Botanical", "coastal": "Coastal", "sunset": "Sunset"]
        return names[theme] ?? theme
    }

    private func load(_ source: String, forceDevice: String? = nil) -> CGImage {
        let captureSource = source == "stickers" && device == "mac" ? "insights" : source
        let url = captureDirectory.appending(path: "\(forceDevice ?? device)-\(captureSource).png")
        guard let data = CGImageSourceCreateWithURL(url as CFURL, nil), let image = CGImageSourceCreateImageAtIndex(data, 0, nil) else {
            fatalError("Missing real capture: \(url.path)")
        }
        return image
    }
}

func opaqueImage(_ original: CGImage) throws -> CGImage {
    guard let context = CGContext(data: nil, width: original.width, height: original.height, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else { throw CocoaError(.coderInvalidValue) }
    context.setFillColor(CGColor(gray: 0, alpha: 1))
    context.fill(CGRect(x: 0, y: 0, width: original.width, height: original.height))
    context.draw(original, in: CGRect(x: 0, y: 0, width: original.width, height: original.height))
    guard let image = context.makeImage() else { throw CocoaError(.coderInvalidValue) }
    return image
}

@MainActor
func render() throws {
    let arguments = CommandLine.arguments
    guard arguments.count == 4 else { throw CocoaError(.fileReadInvalidFileName) }
    let language = arguments[3]
    let input = URL(filePath: arguments[1], directoryHint: .isDirectory).appending(path: language)
    let output = URL(filePath: arguments[2], directoryHint: .isDirectory).appending(path: language)
    for device in ["iphone", "ipad", "mac"] {
        guard FileManager.default.fileExists(atPath: input.appending(path: "\(device)-today.png").path) else { continue }
        let size: CGSize = device == "iphone" ? CGSize(width: 440, height: 956) : device == "ipad" ? CGSize(width: 688, height: 917.3333333333) : CGSize(width: 960, height: 600)
        let directory = output.appending(path: device, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        for slide in slides(for: language) {
            let renderer = ImageRenderer(content: ScreenshotArtwork(slide: slide, language: language, device: device, captureDirectory: input, canvas: size).environment(\.colorScheme, .light))
            renderer.scale = 3
            renderer.isOpaque = true
            guard let rendered = renderer.cgImage else { throw CocoaError(.coderInvalidValue) }
            let image = try opaqueImage(rendered)
            let url = directory.appending(path: slide.file + ".png")
            guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else { throw CocoaError(.fileWriteUnknown) }
            CGImageDestinationAddImage(destination, image, [kCGImagePropertyPNGDictionary: [kCGImagePropertyPNGSoftware: "MoodMargins screenshot compositor"]] as CFDictionary)
            guard CGImageDestinationFinalize(destination) else { throw CocoaError(.fileWriteUnknown) }
            print("\(device)/\(slide.file).png \(image.width)×\(image.height)")
        }
    }
    let watchURL = input.appending(path: "watch-check-in.png")
    if let source = CGImageSourceCreateWithURL(watchURL as CFURL, nil), let capture = CGImageSourceCreateImageAtIndex(source, 0, nil) {
        let size = CGSize(width: 208, height: 248)
        let renderer = ImageRenderer(content: Image(decorative: capture, scale: 1).resizable().frame(width: size.width, height: size.height).background(.black))
        renderer.scale = 2
        renderer.isOpaque = true
        let directory = output.appending(path: "watch", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appending(path: "01-check-in.png")
        guard let image = renderer.cgImage, let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else { throw CocoaError(.coderInvalidValue) }
        CGImageDestinationAddImage(destination, try opaqueImage(image), nil)
        guard CGImageDestinationFinalize(destination) else { throw CocoaError(.fileWriteUnknown) }
        print("watch/01-check-in.png \(image.width)×\(image.height)")
    }
}
try render()
