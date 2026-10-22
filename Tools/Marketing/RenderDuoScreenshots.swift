import AppKit
import SwiftUI
import ImageIO
import UniformTypeIdentifiers

/// Composes complete, native Duo captures without cropping, stretching, or invented UI.
struct DuoScreenshot: View {
    var capture: CGImage
    var index: Int
    var language: String
    private var wide: Bool { capture.width > capture.height }
    private var dark: Bool { index == 5 }
    private var ink: Color { dark ? Color(red: 0.96, green: 0.93, blue: 1) : Color(red: 0.36, green: 0.29, blue: 0.47) }
    private var copy: (String, String) {
        let english = [
            ("Small moments.\nEvery feeling.", "Pick a mood. Write a little."),
            ("Open up\nmore room.", "Your journal and recent pages, together."),
            ("Browse beside\nyour journal.", "Find a page without losing your place."),
            ("Keep\nthe moment.", "Your pages save as you write."),
            ("A clearer view\nof your days.", "Mood trends, streaks, and expressive stickers."),
            ("Your quiet space.\nDay or night.", "A notebook that feels like you.")
        ]
        let spanish = [
            ("Pequeños momentos.\nCada emoción.", "Elige tu ánimo. Escribe un poco."),
            ("Abre un mundo\nde espacio.", "Tu diario y tus páginas recientes, juntos."),
            ("Tus páginas,\njunto a tu diario.", "Encuentra una página sin perder tu lugar."),
            ("Conserva\nel momento.", "Tus páginas se guardan mientras escribes."),
            ("Tus días,\ncon más claridad.", "Gráficas, rachas y stickers expresivos."),
            ("Tu espacio sereno.\nDe día y de noche.", "Un cuaderno que va contigo.")
        ]
        let arabic = [
            ("لحظات صغيرة.\nوكل مشاعرك.", "اختر مزاجك واكتب قليلًا."),
            ("افتح مساحة\nأوسع ليومك.", "يومياتك وصفحاتك الأخيرة معًا."),
            ("تصفّح الصفحات\nبجانب يومياتك.", "اعثر على صفحة دون أن تفقد موضعك."),
            ("احتفظ\nباللحظة.", "تُحفظ صفحاتك أثناء الكتابة."),
            ("رؤية أوضح\nلأيامك.", "اتجاهات المزاج والسلاسل وملصقات معبّرة."),
            ("مساحتك الهادئة.\nليلًا ونهارًا.", "دفتر يشبهك ويعبّر عنك.")
        ]
        return (language == "ar" ? arabic : language == "es" ? spanish : english)[index]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: wide ? 30 : 40) {
            VStack(alignment: .leading, spacing: 20) {
                Text("MoodMargins · iPhone Duo")
                    .font(.system(size: wide ? 42 : 36, weight: .semibold, design: .rounded))
                Text(copy.0)
                    .font(.system(size: wide ? 112 : 98, weight: .heavy, design: .rounded))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text(copy.1)
                    .font(.system(size: wide ? 46 : 42, weight: .medium, design: .rounded))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundStyle(ink)
            .frame(maxWidth: .infinity, alignment: .leading)
            Image(decorative: capture, scale: 1)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(.rect(cornerRadius: 30))
                .overlay { RoundedRectangle(cornerRadius: 30).stroke(ink.opacity(0.12), lineWidth: 2) }
                .shadow(color: ink.opacity(0.12), radius: 24, y: 14)
        }
        .padding(.horizontal, wide ? 100 : 80)
        .padding(.top, wide ? 70 : 80)
        .padding(.bottom, 65)
        .frame(width: CGFloat(capture.width), height: CGFloat(capture.height))
        .background(dark ? Color(red: 0.16, green: 0.13, blue: 0.22) : backgrounds[index])
        .environment(\.layoutDirection, language == "ar" ? .rightToLeft : .leftToRight)
    }

    private var backgrounds: [Color] {
        [Color(red: 1, green: 0.86, blue: 0.91), Color(red: 0.91, green: 0.87, blue: 1),
         Color(red: 0.83, green: 0.94, blue: 0.95), Color(red: 1, green: 0.92, blue: 0.82),
         Color(red: 0.87, green: 0.94, blue: 0.86), .black]
    }
}

let root = URL(filePath: FileManager.default.currentDirectoryPath)
let names = ["01-outer-today", "02-inner-today", "03-inner-pages", "04-outer-pages", "05-inner-insights", "06-outer-dark-today"]
for (language, locale) in [("en", "en-US"), ("es", "es-ES"), ("ar", "ar-SA")] {
    let directory = root.appending(path: "appStoreConnect/appStoreVersion/iOS/localizations/\(locale)/placements/app-screenshot/iphone-duo-profile")
    try FileManager.default.createDirectory(at: directory.appending(path: "assets"), withIntermediateDirectories: true)
    for (index, name) in names.enumerated() {
        let sourceURL = root.appending(path: "Marketing/Version1.2.0/SourceCaptures/\(language)/\(name).png")
        guard let source = CGImageSourceCreateWithURL(sourceURL as CFURL, nil),
              let capture = CGImageSourceCreateImageAtIndex(source, 0, nil) else { fatalError("Missing native Duo capture") }
        let renderer = ImageRenderer(content: DuoScreenshot(capture: capture, index: index, language: language))
        renderer.scale = 1
        guard let rendered = renderer.cgImage,
              let context = CGContext(data: nil, width: capture.width, height: capture.height, bitsPerComponent: 8,
                bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else {
            fatalError("Unable to render opaque screenshot")
        }
        context.draw(rendered, in: CGRect(x: 0, y: 0, width: capture.width, height: capture.height))
        guard let image = context.makeImage(),
              let destination = CGImageDestinationCreateWithURL(directory.appending(path: "assets/\(name).png") as CFURL, UTType.png.identifier as CFString, 1, nil) else {
            fatalError("Unable to export screenshot")
        }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { fatalError("Screenshot export failed") }
        print("\(locale)/\(name).png \(image.width)×\(image.height)")
    }
    let manifest = ["placements": names.map { ["fileName": $0 + ".png"] }]
    try JSONSerialization.data(withJSONObject: manifest, options: [.prettyPrinted, .sortedKeys])
        .write(to: directory.appending(path: "manifest.json"))
}
