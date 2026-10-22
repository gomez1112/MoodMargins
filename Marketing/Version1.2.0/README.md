# MoodMargins 1.2.0 — iPhone Duo

The release keeps iOS 27.0 support. On iOS 27.1, the journal uses the native Duo arrangement and reserved-region APIs; Pages uses a native split view. Reflection prompts appear directly above the Today editor. Each window owns its navigation state.

## Screenshot package

`SourceCaptures/{en,es,ar}/` contains fictional, isolated journal data captured from the final app in Bitrig. Both Duo displays are represented: 1398 × 2034 outer and 2853 × 2007 inner. These files are complete native captures, not resized captures from another device.

The 18 opaque marketing compositions are under each locale's `appStoreConnect/appStoreVersion/iOS/localizations/<locale>/placements/app-screenshot/iphone-duo-profile/assets/`. Their manifests specify six images per language. `ContactSheet.png` shows the complete set. The compositions fit the whole source image without distortion or cropping.

Regenerate from the project root:

```sh
xcrun swift -swift-version 6 -default-isolation MainActor -module-cache-path /private/tmp/MoodMargins-Duo-Modules Tools/Marketing/RenderDuoScreenshots.swift
xcrun swift -swift-version 6 -module-cache-path /private/tmp/MoodMargins-Duo-Modules Tools/Marketing/DuoContactSheet.swift . Marketing/Version1.2.0/ContactSheet.png
```

## App previews — recording still required

The headless native Duo recorder returned black frames. Those recordings were rejected during visual QA and discarded. No new Duo preview is included in this release package. Existing remote iPhone/iPad previews remain in their manifests unchanged.

For a later Duo preview, record actual use on a working Duo device/simulator, with fictional journal data and no debug controls. Show mood selection, writing, page browsing, and Insights. Do not substitute a slideshow or a stretched iPad recording. Apple's current Duo preview size is 886 × 1920 portrait or 1920 × 886 landscape, 15–30 seconds, at most 30 fps, with an audio track.

`Tools/Marketing/EncodeDuoAppPreview.swift` prepares real footage with aspect-fit presentation and localized captions. It expects a silent 30-second stereo 48 kHz/16-bit WAV at `/private/tmp/MoodMargins-preview-silence.wav`. The encoder was technically exercised, but no valid Duo source footage was available. Inspect multiple exported frames before adding a preview manifest. Keep the generated JSON/poster outside `appStoreConnect/`; that directory accepts listing files and media only.

References: [Apple screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/), [Apple app-preview specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/app-preview-specifications/).

## Release

Build 16 was uploaded for iOS, macOS, and visionOS. Only iOS, including its Watch companion, is to be submitted, with automatic release after approval. The Mac and Vision builds are uploads only. iOS 1.2.0 (16) is Waiting for Review, with automatic release selected. All 18 Duo screenshots are fully processed and attached. See `ReleasePlan.json` and `QA/Version1.2.0Readiness.md` for verification and the recorded submission outcome.
