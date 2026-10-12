# MoodMargins release preparation — October 11, 2026

The release listing and binaries are prepared. The developer confirmed that the App Privacy label has not yet been published; that manual Apple action remains required before submission. Nothing was submitted to App Review.

The final Watch design uses direct horizontal emotion selection, native note entry, compact history, and readable page details. The notebook-only icon has no emoji. Apple generated the iPhone and Watch App Store icons from the uploaded binary, and the actual CDN images were inspected. The icon is supplied through the build, rather than a separate listing upload.

## Builds

| Platform | Version | Final build | Processing | Release version |
| --- | --- | --- | --- | --- |
| iOS, including Watch | 1.0 | 9 | VALID | Attached |
| macOS | 1.0 | 11 | VALID | Attached |
| visionOS | 1.0 | 8 | VALID | Attached |

All three declare `usesNonExemptEncryption = false`, consistent with the app's use of Apple's protected system services. The final distribution upload compiled, signed, and uploaded every supported platform. Version 1.0 remains PREPARE_FOR_SUBMISSION, with release after approval configured.

## Listing and assets

English, Spanish, and Arabic descriptions, names/subtitles, keywords, promotional copy, support and privacy URLs, copyright, age-rating answers, categories, content rights, pricing, availability, and App Review contact information were applied successfully. Local validation has no diagnostics.

There are 81 public screenshots: six per language for iPhone, iPad, Mac, and Watch, and three per language for Vision. All are RGB PNGs without alpha. Mac captures show the actual native window, sidebar, toolbar, and window controls. Watch images show the final direct-selection design, not the previous card layout.

Nine actual screen-recording previews cover iPhone, iPad, and Mac in all three languages. Apple's asset delivery and video delivery both report COMPLETE for all nine. They use the required dimensions, constant 30 fps H.264 High 4.0, and stereo AAC, run approximately 21–22 seconds, and are under 9 MB each. Theme posters disclose their purchase requirement. No real journal data or fabricated AI output appears.

The interrupted screenshot update hit Apple's ten-image limit because Bitrig uploaded replacements before deleting old images. The developer approved replacing the draft sets and rebuilding the sync baseline. A later Watch replacement was applied in two stages, four images then six, to stay under that limit. Final sets have the correct ordering and matching file checksums. See [AssetVerification.json](AssetVerification.json) for the recorded proof and [README.md](README.md) for reproducible exports.

## Purchases

All three subscriptions and all three permanent theme purchases are READY_TO_SUBMIT, with their localizations, pricing, availability, review notes, and native StoreKit review images present.

| Product | US price |
| --- | --- |
| Plus weekly | $0.99 |
| Plus monthly | $2.99 |
| Plus yearly | $19.99 |
| Botanical, Coastal, Sunset | $1.99 each, permanent non-consumable |

Every Plus plan includes premium themes, AI tags, and AI recaps. Separate themes do not unlock AI. Subscriptions and themes are available in 175 territories. The six review images use Apple's StoreKit testing configuration with identifiers and prices matching the live catalog. That proves the UI, not live billing. Attach the first products to the first app review; Bitrig's submit tool performs that step when submission is requested.

## Verification and remaining actions

Eleven iPhone/iPad UI checks passed, covering all three capture languages, journal autosave, loaded native purchase screens, subscription completion/dismissal, the iPad Plus sheet, and wide page editing. Four Watch model tests passed, and the redesigned Watch interface was inspected on both simulator sizes. The simulator emitted an invalid-frame warning during keyboard-related autosave checks, but assertions passed; the warning was not isolated to an app-owned frame.

CloudKit's production schema was verified against the deployed schema. Main-app journaling uses the user's private iCloud store; the Watch journal is local. Actual two-device production sync and physical-device sandbox purchase/restore remain unverified. Run those checks on TestFlight before publishing.

Publish the label in [MoodMargins → App Privacy](https://appstoreconnect.apple.com/apps/6819079849/distribution/privacy): use the prepared **Data Not Collected** answers in [AppPrivacyWorksheet.md](../Legal/AppPrivacyWorksheet.md), then click **Publish**. Saving a draft is insufficient, and Apple's API cannot publish the label. Confirm the worksheet still matches any services you operate.

The hosted policy is live at [the privacy-policy URL](https://apps.transfinite.us/moodmargins/privacy-policy) and already mentions Private Cloud Compute. Check the cloud off switch and local fallback wording against the local policy draft; have a legal professional review that draft before publishing changes.

App Review contact is Gerard Gomez, transfinite@transfinite.us, +1 914 316 8248. No MoodMargins account or demo login is required. The app is free, with Lifestyle as the primary category and Health & Fitness as secondary. First-release “What's New” is omitted. Once the label and device checks are complete, the prepared versions and products can be submitted for review.
