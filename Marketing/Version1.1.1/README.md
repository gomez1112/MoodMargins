# Version 1.1.1 — marketing and ASO

Prepared October 18, 2026 for MoodMargins: Mood Journal, App Store ID **6819079849**, bundle ID **com.transfinite.MoodMargins**.

**Status: local proposal, ready for copy review.** No 1.1.1 App Store version, build, campaign, or public metadata was created by this work. The submitted 1.1 listings remain the release baseline. Actual availability and review status must be checked again before applying this package.

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

Descriptions: [iOS English](descriptions/iOS/en-US.txt), [Spanish](descriptions/iOS/es-ES.txt), [Arabic](descriptions/iOS/ar-SA.txt); [Mac English](descriptions/macOS/en-US.txt), [Spanish](descriptions/macOS/es-ES.txt), [Arabic](descriptions/macOS/ar-SA.txt); [Vision Pro English](descriptions/visionOS/en-US.txt), [Spanish](descriptions/visionOS/es-ES.txt), [Arabic](descriptions/visionOS/ar-SA.txt).

## What the copy improves

- Replaces the stale Watch-local-only claim with conditional private-iCloud sync.
- Explains free journaling and standard Insights before Plus; clearly separates subscriptions from permanent theme purchases.
- Keeps AI requirements concise, including optional cloud processing and on-device fallback. Does not imply AI works on every device or on the Watch.
- Describes native Mac and visionOS windows using features already implemented.
- Explains that free users can see app recommendations in Customize, and Plus is ad-free.
- Removes weaker English keyword targets such as mindfulness and gratitude. They suggest experiences the app does not specifically provide. Uses relevant writing, mood, and notebook language instead.

## Application scope, after exact copy approval

1. Re-read App Store Connect status. Do not replace a build under review, withdraw a review, or change its release method as part of this marketing package. Create or select 1.1.1 only when Apple allows the next version on that platform.
2. Review shared App Information separately: name/subtitle changes are app-level, not isolated to a version. Apply the Spanish/Arabic proposals only when their release timing is agreed.
3. Apply keywords, promotional text, and the matching description to **1.1.1 only**, for iOS, macOS, and visionOS in en-US, es-ES, and ar-SA. iOS includes the Watch companion; no separate Watch App Store version is proposed.
4. Revalidate name availability, all lengths, actual feature behavior, links, localized product names, and App Store Connect's resulting changes before publishing. Preserve privacy, categories, prices, purchases, availability, and unrelated remote fields.
5. Update Kickstart's internal project description after approval as a separate action; its cached Watch-local-only description is also stale. Keep the internal project name MoodMargins.

The actual project version remains 1.1. A future 1.1.1 binary needs its own matching marketing version and normal distribution checks. No feature changelog is invented for this copy-only task; write What's New from the final shipped changes when that release is assembled. Screenshots, previews, the notebook icon, existing product-page artwork, and campaign budgets are unchanged.

## Measurement and rollout

Use organic distribution first. Before launch, export the previous 14 complete days of App Store Connect acquisition metrics separately for iOS, Mac, locale, territory, and source where Apple provides enough data. Repeat for the first 14 complete days after the approved listing is visible. Record exact visibility dates; flag overlap with the 1.1 launch, holidays, traffic campaigns, featuring, and other listing changes. A before/after difference is directional evidence, not a causal experiment.

Record impressions, product-page views, first-time downloads, and Apple's reported conversion rate with its exact definition. If calculating a separate page-to-download ratio, use compatible unique-user cohorts and the same dates, territory, platform, and source; never mix total impressions with unique views. Suppressed/missing metrics stay unavailable, not zero. No new tracking SDK or device identifier is needed.

Track US iOS mood journal, mood tracker, and private mood tracker; ES iOS diario de ánimo; SA iOS يوميات; and US Mac mood journal with dated snapshots. Different snapshots and storefronts are not interchangeable. Vision Pro has no independent keyword dataset in this research, so do not reuse iOS ranks as visionOS results.

After the metadata settles and sufficient traffic exists, consider one Apple Product Page Optimization screenshot test from the asset brief. Use Apple's confidence reporting and continue until a result is useful; do not promise significance after 14 days or select a winner from a handful of downloads. Keep prices, name, subtitle, keywords, and paid traffic stable during that test where practical. Low traffic is a reason to keep learning, not a reason to buy traffic without a budget decision.

## Remaining owner/release steps

- Review and approve exact localized copy before it is applied externally. Native-language editorial review is recommended for Spanish and Arabic before publishing.
- Verify Watch-to-main-app sync on physical devices using the same Apple Account, including offline edits and eventual delivery. This marketing work did not repeat that device test.
- Obtain current acquisition exports; Kickstart returned no analytics for this project during this audit.
- Check the existing Daily check-ins custom product page's current review state before using its URL. The repository records it as an uploaded, verified **draft**, not a live campaign destination.
- Assemble the eventual 1.1.1 build/release separately if a new binary is needed. This proposal does not submit a review or publish a release.
