# MoodMargins release status — October 18, 2026

## Status verified October 18

Read-only App Store Connect checks confirmed:

| Platform | App Store version | Version 1.1 update |
| --- | --- | --- |
| iOS, including Watch | 1.0 READY_FOR_SALE | Build 2 VALID; attached to the 1.1 PREPARE_FOR_SUBMISSION draft; not submitted |
| macOS | 1.0 READY_FOR_SALE | Build 12 upload FAILED with signing error 90284 for the two Kickstart SDK bundles |
| visionOS | 1.0 READY_FOR_SALE | Build 1 VALID for testing; no 1.1 App Store version created |

The Mac and Vision reviews have finished without withdrawal. Their existing 1.0 version records still have MANUAL release settings, but Apple now reports both as READY_FOR_SALE. Uploading a 1.1 TestFlight build does not automatically create or submit a 1.1 App Store version. The earlier instruction limited the 1.1 public update to iOS, leaving other platforms' updates for testing only.

The shared App Info now has a PREPARE_FOR_SUBMISSION record (`89d2864b-ff1a-4e15-a901-f05b401c8b2e`), so the earlier review-state lock has cleared. Its advertising, messaging/chat, and user-generated-content answers remain false remotely; the prepared disclosures still need to be applied before submitting iOS 1.1. This status check did not change the listing, withdraw reviews, upload another build, or resume the deferred submission.

## October 14–15 version 1.1 preparation history

iOS 1.1 build 2 includes Watch journal sync from commit `fb39f44`. Apple accepted upload `0e84511d-50f1-4c8a-8e86-5b4f9d7b5d62` and reports the build as VALID, with non-exempt encryption set to false. It is attached to iOS version `a3f050e7-940b-40ca-ab23-aa41e53d8575`, which remains PREPARE_FOR_SUBMISSION with release after approval. The archive was scoped to iOS with its embedded Watch companion; all source platform settings were restored afterward. iOS 1.0 remains live.

The attempted iOS submission did not submit anything: the listing updater applied zero of 15 operations because Apple rejected editing the shared age-rating declaration with HTTP 409 STATE_ERROR. At the October 14 check, both App Info records were locked (READY_FOR_SALE and IN_REVIEW), including after creating the iOS 1.1 draft. The new advertising and voluntary feedback features require the prepared advertising, messaging/chat, and user-generated-content disclosures, so those answers must not be omitted just to submit.

On October 15, the developer explicitly chose to keep the existing Mac and Vision reviews and wait to submit iOS 1.1. Neither review has been withdrawn, and iOS 1.1 has not been submitted. Keep build 2 attached to its draft. Before resuming submission, recheck the review states and whether the shared disclosures are editable; do not withdraw either review to bypass the lock.

At the October 14 check, macOS 1.0 was IN_REVIEW and visionOS 1.0 was WAITING_FOR_REVIEW, both with MANUAL release. No new Mac or Vision build was submitted. visionOS 1.1 build 1 is VALID for testing. Apple's build-upload record reports the earlier macOS 1.1 build 12 as FAILED, despite the upload tool reporting completion: error 90284 identifies distribution signing of `KickstartSDK_KickstartSignal.bundle` and `KickstartSDK_KickstartExchange.bundle`. That build is not available in TestFlight and needs a signing correction before another Mac upload.

The Watch now shares the main app's private iCloud journal models and preserves existing local Watch pages during migration. Eight isolated Watch regression tests and Watch simulator compilation/launch passed before this archive; actual same-account Watch/iPhone cloud delivery remains unverified. English, Spanish, and Arabic release notes describe the sync. The developer confirmed the updated hosted privacy policy and SDK App Privacy disclosures are published. No sleep/energy or other dead-code cleanup was performed.

## Version 1.0 history

iOS 1.0 is live, and all six purchase products are approved. macOS 1.0 and the resubmitted visionOS 1.0 are waiting for review. On October 11, 2026, the developer confirmed that the App Privacy label is published.

The final Watch design uses direct horizontal emotion selection, native note entry, compact history, and readable page details. The notebook-only icon has no emoji. Apple generated the iPhone and Watch App Store icons from the uploaded binary, and the actual CDN images were inspected. The icon is supplied through the build, rather than a separate listing upload.

## Builds

| Platform | Version | Final build | Processing | Release version |
| --- | --- | --- | --- | --- |
| iOS, including Watch | 1.0 | 9 | VALID | READY_FOR_SALE |
| macOS | 1.0 | 11 | VALID | WAITING_FOR_REVIEW |
| visionOS | 1.0 | 9 | VALID | WAITING_FOR_REVIEW |

All three declare `usesNonExemptEncryption = false`, consistent with the app's use of Apple's protected system services. The original distribution upload covered every supported platform. The October 14 upload produced only visionOS build 9; the app target's platform settings were temporarily narrowed for that archive and fully restored afterward. The pending Mac and Vision versions retain release after approval.

## visionOS resubmission

Build 9 includes commits `6748fac` and `278876d`: native visionOS materials and legible controls, shared three-page onboarding, corrected Lottie orientation, native StoreKit controls with reused loaded products, actionable purchase recovery, and private error diagnostics. The mood order is unchanged.

Apple processed build `c510de20-fc95-45e4-8092-63e57d77b036` as VALID and attached it to visionOS version `19759d81-d4fb-44b5-8a5e-51cbb0ea36c1`. The existing review submission `fd716f2a-27a3-4d80-b726-4b37394b86f3` was resubmitted at `2026-10-14T10:41:56.515Z`; both the version and submission report WAITING_FOR_REVIEW. The prior reviewed binary was build 8.

The standard submit tool created an empty draft, then failed because the version still belonged to the rejected submission. Recovery used Apple's documented review-item `resolved` and submission `submitted` updates to resubmit the existing item with build 9. Empty draft `247f2ae1-fa3e-4b66-8407-5469ac5ebd7e` remains READY_FOR_REVIEW with zero items; Apple rejects cancellation in that state. It was not submitted and does not contain the active version.

Thirteen local visionOS purchase/recovery/UI test runs and two subsequent English/Arabic onboarding tests passed on the 27.0 simulator. These do not verify Apple's physical-device sandbox. Live AI on Vision Pro also remains unverified: one simulator run crashed inside Foundation Models after inheriting simulated purchases; onboarding tests passed after purchase state was isolated. The original App Review message did not identify the failed purchase or its error code, so the original sandbox failure's precise cause remains unconfirmed.

## Listing and assets

English, Spanish, and Arabic descriptions, names/subtitles, keywords, promotional copy, support and privacy URLs, copyright, age-rating answers, categories, content rights, pricing, availability, and App Review contact information were applied successfully. Local validation has no diagnostics.

On October 12, the developer authorized uploading the creative asset package. The **Daily check-ins** custom page now has three localizations, 18 iPhone/iPad screenshots, and localized header/search artwork. Its six creative images are also placed on the default iOS page. All 24 images processed, all 30 placements match the package, and all six screenshot groups have the approved order. Both pages remain drafts. See [ProductPage/Deployment.json](ProductPage/Deployment.json).

There are 81 public screenshots: six per language for iPhone, iPad, Mac, and Watch, and three per language for Vision. All are RGB PNGs without alpha. Mac captures show the actual native window, sidebar, toolbar, and window controls. Watch images show the final direct-selection design, not the previous card layout.

Nine actual screen-recording previews cover iPhone, iPad, and Mac in all three languages. Apple's asset delivery and video delivery both report COMPLETE for all nine. They use the required dimensions, constant 30 fps H.264 High 4.0, and stereo AAC, run approximately 21–22 seconds, and are under 9 MB each. Theme posters disclose their purchase requirement. No real journal data or fabricated AI output appears.

The interrupted screenshot update hit Apple's ten-image limit because Bitrig uploaded replacements before deleting old images. The developer approved replacing the draft sets and rebuilding the sync baseline. A later Watch replacement was applied in two stages, four images then six, to stay under that limit. Final sets have the correct ordering and matching file checksums. See [AssetVerification.json](AssetVerification.json) for the recorded proof and [README.md](README.md) for reproducible exports.

## Purchases

All three subscriptions and all three permanent theme purchases report APPROVED as of October 14, with their localizations, pricing, availability, review notes, and native StoreKit review images present.

| Product | US price |
| --- | --- |
| Plus weekly | $0.99 |
| Plus monthly | $2.99 |
| Plus yearly | $19.99 |
| Botanical, Coastal, Sunset | $1.99 each, permanent non-consumable |

Every Plus plan includes premium themes, AI tags, and AI recaps. Separate themes do not unlock AI. Subscriptions and themes are available in 175 territories. The six review images use Apple's StoreKit testing configuration with identifiers and prices matching the live catalog. That proves the UI, not live billing. The products have now been approved with the iOS release and do not require another first-product submission for visionOS.

## Verification and remaining actions

Eleven iPhone/iPad UI checks passed, covering all three capture languages, journal autosave, loaded native purchase screens, subscription completion/dismissal, the iPad Plus sheet, and wide page editing. Four Watch model tests passed, and the redesigned Watch interface was inspected on both simulator sizes. The simulator emitted an invalid-frame warning during keyboard-related autosave checks, but assertions passed; the warning was not isolated to an app-owned frame.

CloudKit's production schema was verified against the deployed schema. Main-app journaling uses the user's private iCloud store; the Watch journal is local. Actual two-device production sync and physical-device sandbox purchase/restore remain unverified. Run those checks on TestFlight before publishing.

The developer confirmed publication of the label in [MoodMargins → App Privacy](https://appstoreconnect.apple.com/apps/6819079849/distribution/privacy). Publication status is based on that confirmation because Apple’s listing API does not expose it. The implementation audit remains in [AppPrivacyWorksheet.md](../Legal/AppPrivacyWorksheet.md).

The hosted policy is live at [the privacy-policy URL](https://apps.transfinite.us/moodmargins/privacy-policy) and already mentions Private Cloud Compute. Check the cloud off switch and local fallback wording against the local policy draft; have a legal professional review that draft before publishing changes.

App Review contact is Gerard Gomez, transfinite@transfinite.us, +1 914 316 8248. No MoodMargins account or demo login is required. The app is free, with Lifestyle as the primary category and Health & Fitness as secondary. First-release “What's New” is omitted. The remaining verification work is the physical-device purchase/restore, live Vision Pro AI, and two-device iCloud checks above. iOS is released; macOS and visionOS await Apple's review.
