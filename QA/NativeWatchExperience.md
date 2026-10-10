# Native Watch experience — October 10, 2026

The Watch app now uses vertically paginated native tabs for Today and Recent pages. The quick check-in contains a large animated mood control and native note entry. A native, Crown-scrollable list presents the five mood choices. Recent entries open a separate, readable detail view. Save-status copy is removed; selection saves immediately, and note changes retain the existing debounce and lifecycle saves. Save errors remain visible.

Watch emoji frames are exported from the exact five Lottie files used by the phone app through the already-resolved DotLottiePlayer framework. The 178 transparent, 160-pixel frames total 1,811,524 bytes. Playback uses SwiftUI TimelineView at 15 fps; only the active check-in/detail or selected mood animates. It pauses for Reduce Motion, a dimmed display, inactive scenes, and disappeared views. Notes and history are marked privacy-sensitive for the Always On display. No UIKit bridge or additional package dependency was introduced.

Regenerate the assets with `zsh Tools/Assets/ExportWatchMoodFrames.sh <existing-dotlottie-ios-checkout>`. The exporter handles the core's millisecond timing, preserves its already-rendered frame zero, validates nonempty frames, and caps frame counts to prevent an unexpectedly large export. Generated counts and durations live in WatchMoodAnimationFrames.swift.

## Verification

- Watch and companion iOS Bitrig builds passed using the 27.0 SDKs and Swift 6.4. Final iOS, macOS, and visionOS Simulator builds also passed with no diagnostics.
- All four isolated Watch model tests passed, including explicit mood selection, persistence and stable entry identity, cancellation/lifecycle saving, and protection of unreadable storage.
- Inspected the live Watch check-in, native note control, and native mood sheet; all five choices are reachable by scrolling. Did not add fictional entries to the user's journal during this inspection.
- Verified every generated asset exists and every mood includes distinct animation frames. Inspected an exported frame for correct color and transparency.
- New accessibility copy is localized in English, Spanish, and Arabic. Native labels and rows retain system typography and wrapping.

The 40 mm built-in simulator did not boot after a device change. Returned the device selection to 49 mm, but a later preview launch still waited for boot after successful compilation and was interrupted. The live 49 mm inspection above happened before the device change; the 40 mm runtime layout remains unverified. Watch entries continue to persist locally; this change does not add phone synchronization.
