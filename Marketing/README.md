# MoodMargins App Store artwork

The listing contains six marketing screenshots for iPhone, iPad, and Mac in English, Spanish, and Arabic, plus one Watch check-in screenshot in each language. These use the actual app's rendered SwiftUI views and bundled Lottie frames with fictional entries. They contain no real journal, fabricated purchase access, or simulated AI results.

Upload-ready files and display-order manifests are under `appStoreConnect/appStoreVersion/`. Preview sheets: [English](ScreenshotPreview-English.png), [Spanish](ScreenshotPreview-Spanish.png), and [Arabic](ScreenshotPreview-Arabic.png). The original localized captures are in `SourceCaptures/` for reproducibility. Mac captures show the actual feature views in their own native window with navigation chrome excluded. Theme artwork crops the shared theme preview rather than presenting an unloaded StoreKit product as a working purchase screen.

| Device | PNG pixels | Listing display type |
| --- | --- | --- |
| iPhone 6.9-inch | 1320 × 2868 | app-iphone-67 |
| iPad 13-inch | 2064 × 2752 | app-ipad-pro-3gen-129 |
| Mac | 2880 × 1800 | app-desktop |
| Apple Watch Series 12 / 46 mm | 416 × 496 | app-watch-series-10 |

There are 57 public exports in total and six separate product review images. Exports are RGB PNGs without alpha. [Apple screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/).

To regenerate the posters on the installed Xcode toolchain, run from the project root:

```sh
xcrun swift -swift-version 6 -default-isolation MainActor -module-cache-path /private/tmp/MoodMargins-Screenshot-Modules Tools/Marketing/RenderScreenshots.swift Marketing/SourceCaptures /private/tmp/MoodMargins-Artwork en
```

Use `es` or `ar` for the other languages. Keep the native simulator screenshots at their original resolution.

`JournalCaptureUITests` launch a DEBUG-only in-memory journal, select real tabs and theme previews, and capture each locale. The Mac capture test uses ScreenCaptureKit's current-process window filter; it never captures the desktop. Capture mode and its sample content are excluded from Release. Watch capture mode also avoids writes to the normal journal. `Tools/QA/CheckWatchAutosave.sh` tests the actual Watch model source with four isolated Swift Testing fixtures, without adding an app dependency.

Review and apply the complete listing in **Bitrig → Project Settings → Distribute → App Store Listing**. See [ReleaseReadiness.md](ReleaseReadiness.md) for remaining release steps.

The six product review images show the real Customize benefits or theme preview, at a supported iPhone resolution. Catalog loading is pending metadata application; replace these review images with loaded purchase screens after propagation and device testing before submission. Public artwork does not show unavailable StoreKit controls.
