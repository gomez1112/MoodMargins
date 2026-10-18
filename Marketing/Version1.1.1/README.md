# Version 1.1.1 — marketing and ASO

Prepared October 18, 2026 for MoodMargins: Mood Journal, App Store ID **6819079849**, bundle ID **com.transfinite.MoodMargins**.

**Status: version 1.1.1 is staged locally for upload after 1.1 approval.** The project and local listing now use 1.1.1, with source build 15 across the app and its embedded targets. No 1.1.1 build or metadata has been uploaded, applied, or submitted. A live check on October 18 still showed 1.1 Waiting for Review on all three platforms. See the [conditional release plan](ReleasePlan.json) and [preparation checks](../../QA/Version1.1.1Readiness.md).

## Recommended direction

Lead with a small daily habit: choose a mood, write a few words, and look back. Keep the established English name and subtitle. Make the Spanish and Arabic names explain the product while preserving their current brands. Give each platform its own description rather than copying a Watch-focused description onto Mac and Vision Pro.

The highest-priority correction is factual: the old descriptions say Watch pages do not sync. The implementation and 1.1 release notes now include automatic private-iCloud sync. This package corrects that wording in all three languages, explains that sync requires iCloud, and avoids promising immediate delivery. Physical-device sync is still a release-verification step, not something an ASO score proves.

## Exact proposed name and subtitle changes

| Locale | Current name | Proposed name | Current subtitle | Proposed subtitle |
| --- | --- | --- | --- | --- |
| en-US | MoodMargins: Mood Journal | MoodMargins: Mood Journal | Daily Diary & Emotion Tracker | Daily Diary & Emotion Tracker |
| es-ES | MoodNotas | MoodNotas: Diario de ánimo | Emociones y reflexión diaria | Emociones y reflexión diaria |
| ar-SA | دفتر مزاج | دفتر مزاج: يوميات ومشاعر | تتبّع مشاعرك وتأمل يومك | دوّن يومك واكتشف أنماطك |

The Arabic subtitle adds daily writing and pattern discovery without repeating the name's mood/emotion wording. Name availability has not been reserved or validated by Apple. The English descriptor already has some search visibility; there is no evidence here that changing it would help.

## Review the complete package

- [ListingDraft.json](ListingDraft.json): exact names, subtitles, keywords, promotional text, URLs, target platforms, and paths to all nine complete descriptions.
- [Research.md](Research.md): dated Kickstart evidence, limitations, keyword decisions, and Apple sources.
- [AssetBrief.md](AssetBrief.md): screenshot and preview messaging, with a controlled test proposal.
- [LaunchCopy.md](LaunchCopy.md): ready-to-use English, Spanish, and Arabic organic launch copy.
- [Validation.json](Validation.json): automated checks and field lengths for this exact package.
- [KeywordTrackingPlan.json](KeywordTrackingPlan.json): owner-approved eight-tracker batch, added to Kickstart and verified on October 18; [initial ranking snapshots and readback results](KeywordTrackingResults.json).
- [PrivacyPreservingAnalytics.md](PrivacyPreservingAnalytics.md): Apple's existing reports and a proposal for optional feature counters; no analytics instrumentation has been added.
- [ReleasePlan.json](ReleasePlan.json): predecessor approval requirements, platform release methods, and the deferred upload/submission scope.

Descriptions: [iOS English](descriptions/iOS/en-US.txt), [Spanish](descriptions/iOS/es-ES.txt), [Arabic](descriptions/iOS/ar-SA.txt); [Mac English](descriptions/macOS/en-US.txt), [Spanish](descriptions/macOS/es-ES.txt), [Arabic](descriptions/macOS/ar-SA.txt); [Vision Pro English](descriptions/visionOS/en-US.txt), [Spanish](descriptions/visionOS/es-ES.txt), [Arabic](descriptions/visionOS/ar-SA.txt).

## What the copy improves

- Replaces the stale Watch-local-only claim with conditional private-iCloud sync.
- Explains free journaling and standard Insights before Plus; clearly separates subscriptions from permanent theme purchases.
- Keeps AI requirements concise, including optional cloud processing and on-device fallback. Does not imply AI works on every device or on the Watch.
- Describes native Mac and visionOS windows using features already implemented.
- Explains that free users can see app recommendations in Customize, and Plus is ad-free.
- Removes weaker English keyword targets such as mindfulness and gratitude. They suggest experiences the app does not specifically provide. Uses relevant writing, mood, and notebook language instead.

## Prepared scope and deferred application

1. Re-read App Store Connect status. Do not replace a build under review, withdraw a review, or change its release method as part of this marketing package. Create or select 1.1.1 only when Apple allows the next version on that platform.
2. Name/subtitle changes are app-level, not isolated to a version. The discussed Spanish/Arabic names and subtitles are staged locally with this package; apply them only with the eligible 1.1.1 release, preserving the active 1.1 reviews.
3. Apply keywords, promotional text, and the matching description to **1.1.1 only**, for iOS, macOS, and visionOS in en-US, es-ES, and ar-SA. iOS includes the Watch companion; no separate Watch App Store version is proposed.
4. Revalidate name availability, all lengths, actual feature behavior, links, localized product names, and App Store Connect's resulting changes before publishing. Preserve privacy, categories, prices, purchases, availability, and unrelated remote fields.
5. Update Kickstart's internal project description after approval as a separate action; its cached Watch-local-only description is also stale. Keep the internal project name MoodMargins.

The user requested preparing this package and uploading/submitting it after 1.1 approval. The matching project settings, three local version files, all nine metadata localizations, truthful release notes, and updated review instructions are prepared. The release notes explain the App Store information refresh; they do not reannounce Watch sync as a new 1.1.1 feature. Screenshots, previews, the notebook icon, existing product-page artwork, and campaign budgets are unchanged.

Do not click Update Listing, Upload, or Submit while the predecessor condition is unmet. Apple requires the current version to be Ready for Distribution to create the next version. Mac and Vision 1.1 use manual release, so an approved version may still need release before 1.1.1 can be created/submitted. This preparation does not change those release methods or release 1.1. [Apple: Create a new version](https://developer.apple.com/help/app-store-connect/update-your-app/create-a-new-version/).

## Measurement and rollout

Use organic distribution first. Before launch, export the previous 14 complete days of App Store Connect acquisition metrics separately for iOS, Mac, locale, territory, and source where Apple provides enough data. Repeat for the first 14 complete days after the approved listing is visible. Record exact visibility dates; flag overlap with the 1.1 launch, holidays, traffic campaigns, featuring, and other listing changes. A before/after difference is directional evidence, not a causal experiment.

Record impressions, product-page views, first-time downloads, and Apple's reported conversion rate with its exact definition. If calculating a separate page-to-download ratio, use compatible unique-user cohorts and the same dates, territory, platform, and source; never mix total impressions with unique views. Suppressed/missing metrics stay unavailable, not zero. No new tracking SDK or device identifier is needed.

Track US iOS mood journal, mood tracker, and private mood tracker; ES iOS diario de ánimo; SA iOS يوميات; and US Mac mood journal with dated snapshots. Different snapshots and storefronts are not interchangeable. Vision Pro has no independent keyword dataset in this research, so do not reuse iOS ranks as visionOS results.

After the metadata settles and sufficient traffic exists, consider one Apple Product Page Optimization screenshot test from the asset brief. Use Apple's confidence reporting and continue until a result is useful; do not promise significance after 14 days or select a winner from a handful of downloads. Keep prices, name, subtitle, keywords, and paid traffic stable during that test where practical. Low traffic is a reason to keep learning, not a reason to buy traffic without a budget decision.

## Remaining owner/release steps

- Recheck predecessor approval and whether Apple allows a new version before applying this prepared copy. Native-language editorial review remains recommended for Spanish and Arabic.
- Verify Watch-to-main-app sync on physical devices using the same Apple Account, including offline edits and eventual delivery. This marketing work did not repeat that device test.
- Obtain current acquisition exports; Kickstart returned no analytics for this project during this audit.
- Check the existing Daily check-ins custom product page's current review state before using its URL. The repository records it as an uploaded, verified **draft**, not a live campaign destination.
- Archive/upload the prepared 1.1.1 code after the approval gate, verify processed builds, apply the local listing, and submit eligible platforms using the existing release methods. No automatic background approval monitor has been configured.
