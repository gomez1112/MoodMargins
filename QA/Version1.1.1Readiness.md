# Version 1.1.1 release preparation — October 18, 2026

**Prepared locally; upload and submission are held for version 1.1 approval.** All main-app platforms and the Watch companion compile in Release. The source marketing version is 1.1.1 and source build number is 15. The owner requested the previously presented marketing/ASO update and conditionally authorized its upload/submission after 1.1 approval.

## Live predecessor status

Read-only App Store Connect checks before and after preparation returned:

| Platform | Version / build | State | Release method |
| --- | --- | --- | --- |
| iOS, including Watch | 1.1 / 2 | Waiting for Review | After approval |
| Mac | 1.1 / 14 | Waiting for Review | Manual |
| Vision Pro | 1.1 / 1 | Waiting for Review | Manual |

All selected 1.1 builds were VALID at the initial check. Released 1.0 versions remain Ready for Sale. There is no 1.1.1 App Store version yet; no build was uploaded, listing applied, review withdrawn, release method changed, or review submission created in this task. Source preparation is not evidence that Apple approved the predecessor.

## Prepared changes

- Updated all 12 target/configuration version pairs to 1.1.1 (15), including the main app, Watch, widgets, and test bundles. Build 15 is above the latest submitted Mac build, 14; the distribution tool may assign a different build number during upload.
- Staged all three local version.json files at 1.1.1, retaining iOS automatic release and Mac/Vision manual release.
- Staged the discussed English, Spanish, and Arabic metadata: shared names/subtitles, keywords, promotional text, and nine platform-specific descriptions. URLs and unrelated fields are preserved.
- Added truthful localized What's New text explaining the App Store information refresh. Watch sync and the feedback board are existing 1.1 features, not new 1.1.1 features.
- Updated review notes to distinguish the metadata-focused patch from existing functionality, preserving the working contact information and no-account instructions.

No Swift implementation, dependency, entitlement, CloudKit schema/model, privacy policy, purchase, price, availability, screenshot, preview, header/search asset, icon, or lock.json was changed. The optional feature-analytics proposal remains unimplemented. Kickstart's eight keyword trackers are separate App Store search monitoring, not in-app telemetry.

## Build and integrity checks

The selected toolchain is /Applications/Xcode.app with Apple Swift 6.4 (swiftlang-6.4.0.34.1). iOS, watchOS, macOS, and visionOS SDKs and deployment targets remain 27.0. Main app, Watch, and unit tests use Swift 6 mode with Approachable Concurrency. Existing widget and UI-test Swift 5 language settings are preserved; this marketing patch does not include an unrelated language-mode migration. Compiler version, language mode, and deployment targets are distinct settings.

Commands run through Bitrig:

```sh
bitrig preview -platform iOS -platform watchOS -platform macOS -platform visionOS -configuration Release
bitrig build -destination 'generic/platform=watchOS Simulator' -destination 'generic/platform=visionOS Simulator' -destination 'generic/platform=macOS' -destination 'generic/platform=iOS' -configuration Release --keep-going
```

The preview built and launched the selected iOS simulator. The user was not previewing Watch, Mac, or Vision, so preview skipped those; the second command verified their Release builds separately. All four destinations succeeded. No Mac or Vision app was launched as part of those build checks.

Preview log: 2026-10-18T19-17-45-8a96ab9d.log. Multi-platform build log: 2026-10-18T19-18-48-1bfac255.log, in this project's Bitrig build logs directory. The [build verification record](Version1.1.1BuildVerification.json) captures the results and bundle versions; temporary built-app paths can be replaced by later builds.

The actual iOS app, embedded iOS widget, embedded Watch app, standalone Watch simulator app, Mac app, and Vision simulator app all reported 1.1.1 (15). The Mac Release app also passed codesign --verify --deep --strict outside the restricted command shell. This verifies normal Release signatures, not a future App Store distribution export. Preserve the existing [Mac resource-bundle archive signing fix](MacDistributionSigning.md); archive/export and Apple's processing must still be checked during the authorized upload.

The build reported seven warnings across the four destinations: two Watch Release unreachable-code warnings at WatchJournalSession.swift:24 and five App Intents metadata-extraction notices for targets without an AppIntents.framework dependency. The iOS preview reported three corresponding warnings. No compiler/linker errors occurred. Application code was not changed to address existing warnings in a metadata-only patch.

Source integrity checks confirmed exact agreement between the prepared copy and all nine local listing localizations, version/build agreement in every configured target, canonical text endings, unchanged screenshots/previews and sync lock, and unchanged prices/privacy/CloudKit files. Main and Watch Info.plist still declare ITSAppUsesNonExemptEncryption false and remote-notification background support. Both retain iCloud.com.transfinite.MoodMargins; the already-deployed production schema is unchanged. [Production verification history](CloudKitProduction.md).

## Listing validation

Bitrig's App Store listing validator passed with nine existing warnings for missing local copies of videos already placed in App Store Connect: iPhone/iPad/Mac previews in the three languages. Apple's service does not offer those videos for download. The unchanged placements retain the existing remote videos; no file was fabricated or a different video substituted to silence a warning. Reuse/inheritance must still be confirmed when the new remote versions are created. The exact Mac English preview name is preserved.

No runtime unit/UI tests were rerun for version and listing changes. This does not supersede previously recorded functional verification. Physical two-device Watch/iPhone delivery, production purchases/restores, live Vision AI, native-language editorial review, and Apple name availability remain outside what these build checks prove.

## Deferred upload/submission sequence

1. Read current Apple version/review states again. Upload 1.1.1 only after the predecessor approval condition is satisfied for every platform in that upload batch. If 1.1 is rejected, resolve its review issue before proceeding with the marketing patch.
2. Apple requires the current version to be Ready for Distribution before creating the next App Store version. Mac and Vision 1.1 are manual releases, so approval can leave them Pending Developer Release. Do not silently release them or change release methods; handle that step explicitly before their next-version submission. [Apple: Create a new version](https://developer.apple.com/help/app-store-connect/update-your-app/create-a-new-version/).
3. Revalidate the prepared listing and confirm the intended platform scope. The upload helper archives configured platforms together; do not upload a still-unapproved platform accidentally. Do not alter or replace active 1.1 submissions.
4. Use Bitrig's upload tool after the condition is met. Check actual uploaded version/build, processing VALID status, encryption answers, and archive signing. Match the 1.1.1 build to the correct platform; do not attach an old 1.1 build.
5. Apply the prepared local listing with the normal tracked sync workflow, preserving remote-only values and resolving genuine conflicts without hand-editing lock.json. Confirm names are available and inherited screenshots/previews remain present. Do not repeat the old age-rating workaround blindly; inspect current editable App Info if a sync error occurs.
6. Submit the eligible 1.1.1 platforms using their existing release methods and verify Apple's returned review-submission states. No extra product, campaign, custom page, or analytics change is included.

The [release plan](../Marketing/Version1.1.1/ReleasePlan.json) records this conditional scope. No automatic background approval monitor or scheduled upload job has been configured.
