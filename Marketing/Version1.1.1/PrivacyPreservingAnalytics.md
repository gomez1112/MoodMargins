# Private analytics for MoodMargins

Prepared October 18, 2026. **Recommendation only:** no analytics SDK, collection endpoint, event instrumentation, consent screen, dependency, or privacy-policy change was added. Keyword tracking in Kickstart is a separate activity: it monitors App Store rankings, not people using the app. Its exact proposed batch is in [KeywordTrackingPlan.json](KeywordTrackingPlan.json).

## Start with Apple's existing reports

App Store Connect Analytics already provides discovery/download/conversion metrics, sessions, active devices, retention, and commerce reports across supported main-app platforms. Usage metrics cover people who opted to share analytics with developers; coverage is incomplete and small populations can suppress results. This does not require adding an analytics SDK to MoodMargins. Apple's reports do not provide arbitrary custom events for individual screens. [Apple: Measuring app performance](https://developer.apple.com/app-store-connect/analytics/), [metric definitions](https://developer.apple.com/help/app-store-connect-analytics/reference/metrics-definitions).

For 1.1.1 ASO, begin with these reports. In Kickstart, open the project and fetch reports in Analytics; the latest read returned no available analytics. Compare with the app's Analytics in App Store Connect to distinguish a missing Kickstart import from unavailable Apple data. Some App Store metrics require at least five first-time downloads or pre-orders. Missing data is not zero activity, and an in-app SDK would not repair Apple's report availability. [Apple: Metric definitions](https://developer.apple.com/help/app-store-connect-analytics/reference/metrics-definitions).

Use Apple's acquisition and retention definitions, dates, source, and platform consistently. Do not infer custom-screen behavior from sessions, or infer private Watch-companion activity from an iOS total. Check which device/platform breakdowns Apple actually exposes. Ask real testers about unclear workflows through the existing optional feedback board, without asking them to include private journal content.

## If feature-use counts are needed later

An additional, separately approved implementation could send a small set of consented counters to an endpoint under the developer's control, using native networking rather than adding another SDK by default. No endpoint or hosting provider has been selected or configured. Review the full ingress, hosting, logging, and storage path before making privacy promises.

| Question | Proposed counter | Counting rule |
| --- | --- | --- |
| Is Today used? | today_opened | Count actual screen entry, not SwiftUI body updates. |
| Do people revisit pages? | pages_opened | Count screen entry; never collect a page identifier or search. |
| Are Insights discovered? | insights_opened | Count screen entry; no graph values, mood values, or recap content. |
| Is Customize discovered? | customize_opened | Count screen entry; no theme selection, entitlement, or ad-interaction payload. |
| Is onboarding completed? | onboarding_completed | Count completion; distinguish it from dismissing onboarding. |
| Are new journal pages created? | page_created | Optional: increment once after first successful persistence of a new page, never for every autosave or edit. No page ID is transmitted. |

These would be interaction totals, not unique-person counts, session replays, individual timelines, or cross-device funnels. A person using three devices can contribute three sets of counts. Keep Apple's aggregate retention reports for retention; do not quietly introduce an installation identifier to derive it. Journal-creation frequency can itself be sensitive, so the optional final counter deserves explicit review and is not required for a useful first phase.

### Proposed collection boundaries

- Add a clear, optional “Share basic usage statistics” setting, off by default. Explain the exact counters and destination. Refusing must not restrict journaling, Insights, sync, Plus, or feedback.
- Record only after consent. Do not backfill prior activity. Turning the setting off cancels pending uploads and deletes unsent counters. Keep this preference local to each device; private iCloud journal sync does not grant analytics consent on another device.
- Allowlist event names and numeric counts. Reject arbitrary dictionaries and free-form values. Aggregate on device into coarse time buckets before upload; no event-by-event timestamps, navigation paths, session durations, or journal dates in the payload.
- Exclude journal text, mood/sticker values, tags, activities, search queries, note lengths, AI prompts/results, page/model IDs, photos, dictation, and CloudKit/account details. Never inspect private journal records to enrich analytics. Existing journal sync remains in its private database.
- Add no user ID, installation ID, advertising ID, device fingerprint, transaction/receipt value, subscription/premium status, or persistent session identifier. Do not join these counters with Exchange, Signal, support emails, purchases, or other datasets.
- If segmentation is useful, limit it to broad platform and release version. Avoid locale, country, device model, or exact OS/build combinations that create tiny cohorts; use Apple's existing aggregate marketing breakdowns instead.
- Network infrastructure necessarily processes connection metadata such as IP addresses. Review and disable unnecessary access logs, request-body logging, cookies, and IP-based profiling throughout the host/CDN path. Do not call reports anonymous merely because the app omitted a user ID.
- Keep only aggregate totals, suppress small groups, and define retention before deployment. Proposed defaults for review: discard unsent counters after seven days and keep aggregate daily totals for 90 days. These are product choices, not Apple's prescribed periods. Without identity, small-group thresholds based on reports cannot truthfully be described as thresholds based on distinct people.
- Treat uploads as cancellable, best-effort work with bounded storage and network use. No analytics request may block saving, opening the app, purchasing, or CloudKit sync. Document loss/retry/deduplication behavior; do not present approximate totals as audited counts.
- Keep development, simulator, automated-test, and marketing-capture traffic offline or in isolated local fixtures. Do not pollute production totals while validating UI.

## Privacy disclosures and implementation checks

Apple categorizes feature interactions as Product Interaction and measuring feature use as Analytics. Assess whether the final data is linked to identity based on the actual pipeline, not the absence of a name field. Pure product analytics is not automatically Apple's cross-app advertising “tracking.” Opt-in alone does not exempt recurring analytics from disclosure. Update the hosted policy and review the App Privacy answers before shipping any new collection. [Apple: App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/).

The current [privacy worksheet](../../Legal/AppPrivacyWorksheet.md) already covers Exchange and Signal, including their distinct purposes and identifiers. Preserve those disclosures. It does not authorize a new general analytics service, nor does an existing Analytics checkbox describe that new service to users. Keep premium-status reporting off unless explicitly requested. Reading Apple reports and transmitting new custom events are separate flows that must be evaluated separately.

Before implementation, agree on questions/events, destination/hosting, retention, consent wording, supported platforms, and disclosures. An optional service is a separate engineering task and a new build. Inspect the actual toolchain and applicable platform instructions before selecting APIs. Obtain approval before adding any third-party dependency.

Acceptance checks should prove that opt-out produces no custom analytics traffic; no journal fields or stable identifiers enter payloads/logs; autosave cannot inflate page-created counts; cancelling or failing an upload cannot affect the journal; turning consent off clears queued work; and developer/test traffic never reaches production. Test against controlled fixtures, not real journal data.

## Recommendation

For the current marketing release, use Apple's aggregate reports and App Store keyword tracking first. Add optional custom feature counters only if those reports leave a concrete product question unanswered. Do not add an analytics SDK simply because Kickstart's report cache is empty.
