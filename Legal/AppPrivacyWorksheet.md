# MoodMargins App Privacy worksheet

Prepared October 4, 2026 from the app and its resolved packages. Confirm this matches the shipped app and any services you operate, then open [App Privacy](https://appstoreconnect.apple.com/apps/6819079849/distribution/privacy), select **Data Not Collected**, and click **Publish**. Apple requires publishing, not just saving a draft. This disclosure cannot be updated through Apple's listing API.

| Questionnaire data type | Current implementation | Purpose if disclosed | Linked to identity | Tracking |
| --- | --- | --- | --- | --- |
| Contact Info → Email Address | No email collected by the app. User-initiated email support is outside the app. | App Functionality | Yes, if support correspondence is retained | No |
| Health & Fitness → Health | Mood selections, sleep, and energy stay on device or in the user's private Apple iCloud store. No developer service receives them. | App Functionality | Private Apple account only | No |
| User Content → Customer Support | No in-app support submission form or upload. | App Functionality | Yes, if voluntarily supplied by email | No |
| User Content → Other User Content | Notes, tags, and activities are local/private iCloud data. AI sends only request context to Apple PCC for temporary processing. | App Functionality | Private Apple account only | No |
| Identifiers → User ID / Device ID | No MoodMargins login, advertising ID, or developer account identifier is transmitted. | Not applicable | Not applicable | No |
| Purchases → Purchase History | Verified StoreKit transactions provide access on device; no developer receipt server. Apple processes purchases. | App Functionality | Apple account only | No |
| Usage Data / Diagnostics | No developer analytics, tracking, crash-upload, or diagnostic-upload service in the app. | Not applicable | Not applicable | No |

The table records the audit, not a recommendation to declare these as collected. Apple's guidance excludes data collected only by Apple and request data discarded after real-time processing. The current app therefore has no developer-collected rows to add. [Apple's App Privacy guidance](https://developer.apple.com/app-store/app-privacy-details/).

Audit scope: SwiftData/CloudKit configuration, Foundation Models request snapshots, StoreKit transaction processing, bundled dotLottie animation loading, EZSwiftData, EZCharts, GentleNotification, and OnboardingKit. The main app has no journal backend, remote animation URLs, advertising SDK, or analytics SDK. Watch entries are local. iCloud sync still needs a real two-device test.

Before release, replace the hosted policy's old claim that AI never uses Private Cloud Compute with [PrivacyPolicy.txt](PrivacyPolicy.txt). This policy is a draft, not legal advice: verify it reflects actual practices, including SDKs, and have a legal professional review it before publishing.
