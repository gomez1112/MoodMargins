# MoodMargins App Store assets

The refreshed listing has 81 screenshots in English, Spanish, and Arabic: six each for iPhone, iPad, Mac, and Watch, and three for Apple Vision Pro per language. Nine App Preview videos cover iPhone, iPad, and Mac in all three languages. Six separate review images show the native StoreKit subscription and theme purchase screens.

Review the complete artwork: [English](ScreenshotPreview-English.png), [Spanish](ScreenshotPreview-Spanish.png), [Arabic](ScreenshotPreview-Arabic.png). [Video contact sheet](AppPreviews/ContactSheet.png) and [upload records](AppPreviews/Uploads.json) are separate. Upload-ready screenshot images and ordered manifests live under `appStoreConnect/appStoreVersion/`; videos live in `AppPreviews/`.

| Platform | Screenshots per language | PNG pixels | Preview pixels |
| --- | --- | --- | --- |
| iPhone | 6 | 1320 × 2868 | 886 × 1920 |
| iPad | 6 | 2064 × 2752 | 1200 × 1600 |
| Mac | 6 | 2880 × 1800 | 1920 × 1080 |
| Watch Series 12, 46 mm | 6 | 416 × 496 | — |
| Apple Vision Pro | 3 | 3840 × 2160 | — |

All public screenshot exports are RGB PNGs without alpha. Watch and Vision captures retain native pixels. Mac images use the actual desktop window with its sidebar, toolbar, and window controls. They do not use an iPad frame. The Mac sticker screenshot scrolls the real Insights screen to the mood distribution. Theme posters explicitly state that Plus or a separate theme purchase is required.

Videos contain live screen recordings of the actual app. They use H.264 High 4.0 at a constant 30 fps, with a 48 kHz stereo AAC track containing silence; they run approximately 21–22 seconds and are under 9 MB each. Native windows fit inside the required preview canvas without stretching. Apple processes video delivery separately from accepting the upload.

Fictional journal entries run in DEBUG-only, isolated capture stores. No real journal content, simulated AI output, or fabricated purchase access appears in public artwork. The six product review captures use Apple's local StoreKit test configuration with the same product identifiers, plan periods, and US prices as the live catalog. These verify the UI; they do not prove on-device sandbox billing.

The asset choices follow [Apple's screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/), [preview specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/app-preview-specifications/), and [accurate metadata guidelines](https://developer.apple.com/app-store/review/guidelines/#accurate-metadata). These checks do not constitute App Review approval.

## Reproduction

Build capture binaries using `bitrig build`. iPhone and iPad still captures are produced by `JournalCaptureUITests` for each language. The Mac utility uses ScreenCaptureKit's current-process filter and exports only the app's own window. It handles native Metal-backed Lottie views without capturing the desktop. Watch capture routes include Today, the horizontal mood selector, Recent Pages, a page detail, and two additional mood pages.

```sh
python3 Tools/Marketing/CaptureNativeMac.py <built-Mac-app> Marketing/SourceCaptures
python3 Tools/Marketing/CaptureSimulatorAssets.py watch <simulator-id> <built-Watch-app> Marketing/SourceCaptures
python3 Tools/Marketing/CaptureSimulatorAssets.py vision <simulator-id> <built-Vision-app> Marketing/SourceCaptures
python3 Tools/Marketing/CaptureSimulatorAssets.py iphone <simulator-id> <built-iPhone-app> Marketing/SourceCaptures
python3 Tools/Marketing/CaptureSimulatorAssets.py ipad <simulator-id> <built-iPad-app> Marketing/SourceCaptures
python3 Tools/Marketing/EncodeAppPreviews.py
xcrun swift -swift-version 6 -default-isolation MainActor -module-cache-path /private/tmp/MoodMargins-Screenshot-Modules Tools/Marketing/RenderScreenshots.swift Marketing/SourceCaptures Marketing/Rendered en
python3 Tools/Marketing/SyncScreenshotAssets.py
```

Render `es` and `ar` before syncing. `Marketing/Rendered/` and raw video recordings are intermediate exports excluded from Git; final listing images, final videos, source stills, review images, and tools are retained. The notebook foreground used by Icon Composer is `MoodMarginsIcon.icon/Assets/Notebook.png`. Apple obtains the App Store icon from the uploaded app build, rather than a listing image upload.

See [ReleaseReadiness.md](ReleaseReadiness.md) for the processed builds, listing status, and the remaining privacy-label action.
