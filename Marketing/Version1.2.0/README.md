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

## App previews — Duo video canceled

The owner canceled the Duo preview video. It is outside the release scope and is not an outstanding release task. The earlier failed recordings were discarded. Existing remote iPhone/iPad previews remain unchanged; the 18 Duo screenshots remain included.

The existing encoder tool is retained, but no further Duo recording, encoding, or upload is authorized by the current request.

## Release

Build 16 was uploaded for iOS, macOS, and visionOS. Only iOS, including its Watch companion, is to be submitted, with automatic release after approval. The Mac and Vision builds are uploads only. iOS 1.2.0 (16) is Waiting for Review, with automatic release selected. All 18 Duo screenshots are fully processed and attached. See `ReleasePlan.json` and `QA/Version1.2.0Readiness.md` for verification and the recorded submission outcome.

Duo support requires the iOS update only. macOS and visionOS releases are independent and do not need matching version numbers. Their uploaded builds can remain unsubmitted. See [Apple's platform guidance](https://developer.apple.com/help/app-store-connect/create-an-app-record/add-platforms).
