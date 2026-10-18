# ASO evidence and decisions

Research date: October 18, 2026. Project: MoodMargins, App Store ID 6819079849. Kickstart's keyword data mode was **serverBacked**. No project settings, tracked keywords, competitors, campaigns, budgets, or App Store metadata were changed.

## Search visibility

These are Kickstart snapshots for this App Store ID, not live personalized searches or guaranteed positions. Popularity uses Apple's relative 0–100 scale, not search counts. Difficulty and entry-barrier assessments are Kickstart estimates. Keep the snapshot date, country, and platform with every value.

| Platform / storefront | Query | Snapshot | Rank | Returned results | Popularity | Difficulty |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| iOS / US | mood journal | 2026-10-18 | 29 | 249 | 7 | 56 |
| iOS / US | mood tracker | 2026-10-17 | 166 | 249 | 9 | 64 |
| iOS / US | private mood tracker | 2026-10-17 | 73 | 241 | 5 | 29 |
| iOS / ES | diario de ánimo | 2026-10-18 | Not present | 243 | 5 | 11 |
| iOS / SA | يوميات | 2026-10-18 | Not present | 248 | 5 | 41 |
| macOS / US | mood journal | 2026-10-18 | Not present | 181 | 7 | 5 |

“Not present” means absent from the returned snapshot's results. It does not establish that the app is unavailable, unindexed, or absent from every search. The discovery tool returned 79 possible US iOS queries, including mood journal at 29, mood check-in at 66, and mood trends at 46. Separate private-mood snapshots differed, so the table uses the dated direct-query result rather than mixing them.

Inference: preserve the English mood-journal descriptor and use more explicit Spanish/Arabic functional names. Broad “mood tracker” is more competitive in this sample, and popularity is not enough to justify changing the app's purpose or title. The Mac result supports investigating discovery there; it does not prove a Mac-specific name change would improve downloads. No independent visionOS search data was available through these research calls.

## Relative popularity sample

Values below came from get_keyword_popularity on October 18, 2026; that endpoint did not expose an underlying snapshot date for each value. They can differ from dated query snapshots.

| US iOS | Value | ES iOS | Value |
| --- | ---: | --- | ---: |
| mood journal | 7 | diario de ánimo | 5 |
| mood tracker | 9 | diario | 44 |
| diary | 43 | emociones | 8 |
| journal | 54 | bienestar | 70 |
| notebook | 59 | cuaderno | 22 |
| self care | 37 | autocuidado | 5 |
| gratitude journal | 32 | reflexión | 5 |
| feelings | 5 | sentimientos | 5 |
| reflection | 5 | gratitud | 5 |
| private diary | 5 | hábitos | 5 |

US macOS: mood journal 7, mood tracker 6, diary 43, journal 54, private diary 5, notebook 59. SA iOS: يوميات، مزاج، مشاعر، مذكرات، تدوين، امتنان، تأمل، كتابة، عادات all returned 5. Those equal low Arabic values do not identify a winning synonym. Favor natural, accurate language rather than interpreting 5 as a measured audience size or zero interest.

## Other Kickstart findings

- Optimization heuristic: **84/100** overall; title 90, subtitle 85, keywords 97, description 64. This audit did not measure a new score for the proposed copy. The older October 11 proposal has different scores; do not present that difference as causal uplift.
- Competitor analysis returned **11 tracked competitors**. The suggestions endpoint simultaneously said no competitors were tracked. Prefer the actual competitor response for that fact; do not automatically act on contradictory suggestions.
- Across cached competitor listings, journal and mood each appeared in 9, diary in 8, daily in 7, mood tracker in 6, thoughts in 6, and private in 4. These are listing-occurrence counts, not search demand or proven conversion drivers. Exclude competitor trademarks and capabilities MoodMargins lacks, such as photo diaries, password locks, and medical treatment.
- Analytics for the requested last seven days: **not available**. Kickstart suggested opening the app's Analytics tab to fetch reports. No settings were changed or exports invented. This does not mean zero downloads or revenue.
- Reviews tool: **no reviews returned**. This is not proof that no rating or review exists in every territory. No social-proof quotes or download counts are added.
- Current Kickstart project copy and all nine repository descriptions still contain the old Watch-local-only claim. The 1.1 release notes and Watch CloudKit persistence contradict that claim. Correct it in the new copy, while retaining the historical approved proposal as a record.

## Keyword decisions

Exact fields live in ListingDraft.json. Do not infer an unmeasured ranking benefit from including a term.

- **English:** preserve Mood Journal in the name and Daily Diary / Emotion Tracker in the subtitle. Use the keyword field for additional relevant terms: feelings, reflection, private, notebook, streaks, thoughts, notes, check in, writing, log, wellbeing. Remove gratitude and mindfulness as primary targets because the app does not offer a dedicated gratitude or meditation workflow. Do not repeat title/subtitle words merely to fill the limit.
- **Spanish:** preserve MoodNotas, adding Diario de ánimo. Retain Emociones y reflexión diaria. Add relevant writing, notebook, feeling, and streak terms in the keyword field. Bienestar has relative demand, but does not justify a treatment claim or a generic wellbeing title.
- **Arabic:** preserve دفتر مزاج, adding يوميات ومشاعر. The revised subtitle describes daily writing and noticing patterns. Use additional keywords for notes, writing, privacy, habits, statistics, and stickers; avoid repeating the name or using an English transliteration solely to occupy space.
- Stop below the maximum if the remaining space would add irrelevant or redundant terms. Apple does not require filling every byte.

## Field limits and editorial checks

Apple's product-page guide describes keywords as up to **100 characters**; its platform-version reference describes a **100-byte** limit. This package conservatively enforces **both** on the complete UTF-8 keyword field, including commas. Arabic must be counted in bytes as well as characters. This check does not claim the already-accepted existing Arabic field was rejected by Apple.

Also validate names/subtitles at 30 characters, promotional text at 170, and each description at 4,000. Use plain text, no comma-following spaces, no repeated keyword entries, no exact title/subtitle token duplication, and keywords longer than two characters. Automated Unicode code-point counts are conservative, including Arabic combining marks; App Store Connect remains the final validator.

Promotional text is a conversion/editorial field; Apple's guide says it does not affect search ranking. Do not keyword-stuff the description to improve a heuristic percentage. Descriptions should help readers decide whether the app fits them. Avoid pricing amounts that would become stale across territories.

## Accuracy sources in the repository

- appStoreConnect/appInfo/localizations/{en-US,es-ES,ar-SA}.json: current localized brands and subtitles.
- appStoreConnect/appStoreVersion/{iOS,macOS,visionOS}/localizations/: current keywords, descriptions, promotional text, and 1.1 release notes. Description hashes match across the three platforms for each locale.
- WatchMoodMargins Watch App/WatchJournalPersistence.swift and WatchMoodMarginsApp.swift: shared MoodEntry models, private CloudKit persistence, migration of previous local pages.
- MoodMargins/Features/Pages/: search, mood filters, and optional tags.
- MoodMargins/Features/Insights/: range selection, trends, streaks, and Plus recap access.
- MoodMargins/Features/Store/ and Shared/Theme/: entitlement-controlled Plus features and the four notebook themes.
- Legal/PrivacyPolicy.txt: iCloud/Watch sync, optional Apple AI, purchases, Exchange, and Signal disclosures.
- Marketing/README.md, ScreenshotPreview-English.png, and ProductPage/ContactSheet.png: existing asset identity and platform presentation.
- Marketing/ProductPage/PagePlan.json: existing Daily check-ins draft and the instruction to defer keyword routing.

## Read-only research calls

get_project; get_keyword_data_mode; get_app_analytics(days: 7); get_reviews; get_competitor_analysis; get_optimization_scores; get_optimization_suggestions; discover_keywords_for_app(US, iOS); get_keyword_popularity(US iOS, ES iOS, SA iOS, US macOS); check_keyword_rankings for each query/country/platform in the visibility table. All targeted MoodMargins / 6819079849. No write endpoint or live SDK submission was used.

## Primary sources consulted

- [Apple: Creating your product page](https://developer.apple.com/app-store/product-page/) — name/subtitle/keyword limits, concise feature copy, promotional text, screenshot ordering, preview presentation.
- [Apple: App Store search](https://developer.apple.com/app-store/search/) — search discovery and relevant product presentation.
- [Apple: Platform version information](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information/) — byte-based keyword reference, field requirements, and version information.
- [Apple: Asset best practices](https://developer.apple.com/app-store/asset-best-practices/) — coherent brand, actual experience, readable localized artwork, safe areas, and search/header creative assets.
- [Apple: Screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/) and [preview specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/app-preview-specifications/) — retained as export references; no new media exported in this task.
