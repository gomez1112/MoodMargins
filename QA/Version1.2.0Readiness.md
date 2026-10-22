# MoodMargins 1.2.0 verification

Source commit: `34c486e`. Release build: 16. Deployment minimum remains iOS 27.0; native iPhone Duo APIs require the installed iOS 27.1 SDK and are guarded at runtime. No new dependency, identifier, analytics event, purchase product, or CloudKit schema was added.

## Completed checks

- iOS 27.0: unit suite, journal autosave UI test, and subscription UI suite passed. One iPad-only test was skipped on iPhone.
- iPhone Duo / iOS 27.1: per-window navigation tests, subscription information test, and browser/editor draft preservation UI test passed.
- Final unit run after the Arabic and navigation adjustments passed on iOS 27.0.
- Release builds passed for iOS device, macOS, visionOS Simulator, and the Watch companion. Remaining build warnings concern existing App Intents metadata extraction and an existing Watch unreachable-code warning.
- Final reflection-prompt UI compiled in the iOS preview and in the iOS device, Mac, and Vision builds.
- Previewed Today, Pages, and 14-day Insights on both Duo displays; opened, closed, rotated, and partially folded the device. The draft and editing position survived opening/closing while typing.
- Checked Arabic right-to-left layout, corrected the distinct Mourn label and streak pluralization, and checked the largest Dynamic Type size with Reduce Motion and Increase Contrast.
- Native screenshot source sizes: outer 1398 × 2034; inner 2853 × 2007. Both displays use the same App Store screenshot group. Compositions preserve the complete source image without cropping or stretching.
- Export-compliance key is false in the main app and Watch companion. Existing private CloudKit and Watch synchronization behavior is preserved.

## Test evidence

Bitrig test logs / result bundles (within the project build directory; retention is limited):

- `2026-10-22T16-18-46-c0cf1047.log`, `2026-10-22T16-19-02-c709123f.xcresult`: iOS 27.0 unit, autosave, subscription suites.
- `2026-10-22T16-22-15-484417e6.log`, `2026-10-22T16-22-25-95cdfdad.xcresult`: Duo navigation and subscription information.
- `2026-10-22T16-26-46-ea390864.log`, `2026-10-22T16-26-52-9d788ec0.xcresult`: Duo browser/editor draft preservation.
- `2026-10-22T16-44-43-9a429d29.log`, `2026-10-22T16-44-49-20b356fc.xcresult`: final iOS 27.0 unit suite.
- `2026-10-22T16-52-33-9fdeb881.log`: final device/Mac/Vision builds after reflection-prompt placement.

## Limits

- The simulator accessibility reader stopped responding after the VoiceOver introduction; screenshot-based UI inspection continued. This is not a completed end-to-end VoiceOver audit.
- Real multiwindow interaction and real-device fold behavior were not exercised. Independent navigation ownership is covered by unit tests.
- No physical-device sandbox purchase or cross-device iCloud synchronization was rerun for this layout change.
- The native headless Duo video recorder produced black frames. Invalid recordings were discarded. Duo app-preview videos are not included; the existing iPhone/iPad previews are preserved remotely. A working device/simulator recording is required to add Duo previews later.

## Release scope

Upload iOS, macOS, and visionOS 1.2.0 (16). Submit iOS, including its Watch companion, for automatic release after Apple approval. Mac and Vision uploads remain available without a new review submission.

## Listing sync workaround

The first submit attempted to edit the live shared app-info record and stopped with HTTP 409 before applying any operation. Creating the editable iOS 1.2.0 version and refreshing the baseline did not correct Bitrig's choice of the shared app-info record. The full listing was backed up before refresh. The exact prepared Arabic and Spanish copy was applied to the editable app-info localization records through Apple's API. Live shared-info values are held locally only while the dedicated listing updater applies the version, then the desired prepared files are restored. The machine-managed lock was never edited by hand.

Existing remote app previews remain present; the nine local missing-video validation warnings are expected because Apple does not provide those files for download.

## Verified submission outcome

On October 22, 2026, Apple accepted iOS 1.2.0 (16) into `WAITING_FOR_REVIEW` with `AFTER_APPROVAL` release. App Store version ID: `aa599dd0-a9d5-4243-ae3e-565c725e9e83`. Review submission ID: `0cc84350-d19f-4b13-9da1-785aae1ebbdd`; submitted at `2026-10-22T21:20:57.73Z`. The attached build is `37778c92-8faa-4fa1-8122-ef0ba627e95f`, processing state `VALID`.

The submission initially reported English/Spanish Duo media processing warnings. A subsequent read verified all six images in each of English, Spanish, and Arabic: all 18 are attached, `COMPLETE`, have no processing errors, and match the local filenames and byte sizes. These transient warnings are resolved. See `Marketing/Version1.2.0/RemoteScreenshotVerification.json`.

The editable shared app-information record is also `WAITING_FOR_REVIEW`, with the prepared Arabic and Spanish names/subtitles verified through Apple's API. The desired local files have been restored. Bitrig's generated lock still points to the existing live shared-info record; do not hand-edit it. After Apple's decision, a regular refresh can reconcile the approved shared information.

macOS 1.2.0 (16) and visionOS 1.2.0 (16) are uploaded and `VALID`, without review submission. The updater also carried forward the previously prepared Mac/Vision 1.1.1 listing drafts; those remain `PREPARE_FOR_SUBMISSION`. No Mac or Vision version was submitted or released in this task.

The app is not live as version 1.2.0 yet. Apple must approve it; automatic release is already selected. New Duo preview video remains the media limitation documented above.
