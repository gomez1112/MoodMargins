# MoodMargins listing handoff

English, Spanish, and Arabic listing copy, 57 public screenshots, and six product review images were applied to App Store Connect on October 4, 2026. The Arabic duplicate-localization conflict was resolved by resuming Update Listing, which reconciled the existing remote localization IDs and regenerated the sync snapshot. All public screenshot uploads are complete and match the local files and ordering; each subscription has prices in 175 territories. Local validation passes, and a final Update Listing reports that the local files already match App Store Connect. No app build, product, or version has been submitted for review by this work.

Version 1.0 iOS build 6 (including Watch), macOS build 8, and visionOS build 5 were uploaded and passed Apple's TestFlight processing checks on October 5, 2026. Their export-compliance declarations are complete and all three are `IN_BETA_TESTING` for the existing internal testing group. Apple has issued the existing tester's invitation; it must be accepted on the tester's device. The signing and packaging fixes are recorded in [SigningRepair.md](../QA/SigningRepair.md), and the access checks in [TestFlightAccess.md](../QA/TestFlightAccess.md).

The reported weekly-subscription price-point HTTP 500 recovered on October 5. Both a paginated lookup and the exact original request, including `limit=8000`, succeeded; the latter returned 800 US price points. The configured US weekly price remains $0.99. Listing validation passes, and Update Listing confirms that the local files already match App Store Connect.

- App: free; Lifestyle, with Health & Fitness as its secondary category.
- Plus: $0.99 weekly, $2.99 monthly, or $19.99 yearly in the US; all three include every premium theme, AI tags, and AI recaps. Other territories equalize from the US baseline.
- Botanical, Coastal, and Sunset: $1.99 each in the US; non-consumable, permanent purchases.
- App Review contact: Gerard Gomez, transfinite@transfinite.us, +1 914 316 8248. No demo account required.
- Hosted privacy-policy URL: https://apps.transfinite.us/moodmargins/privacy-policy.
- First release has no “What's New” text; the app description introduces the features.

Before submission: publish the privacy label using `Legal/AppPrivacyWorksheet.md`, replace the hosted policy's obsolete on-device-only AI claim, confirm Apple's managed PCC access for release use, and test purchases/restore and real iCloud sync on devices. Native StoreKit products cannot load until their local metadata and review screenshots have been applied and propagated. Attach the first in-app purchases and subscriptions to the app's first review submission.

After applying the listing and allowing StoreKit propagation, refresh the six product review images with the loaded native purchase screens. The current review images truthfully show Plus benefits and theme previews while the catalog is pending setup. Review [PrivacyPolicy.txt](../Legal/PrivacyPolicy.txt) with a legal professional before publishing its updated text.
