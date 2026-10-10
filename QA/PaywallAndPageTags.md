# Plus paywall and page tags — October 10, 2026

The Plus paywall uses the active diary palette, a paper card, a washi accent, and previews of the three premium themes. Three brief benefits replace the long introduction. The information button opens a sheet explaining Private Cloud Compute, local fallback, Apple Intelligence readiness, and theme ownership. StoreKit still supplies plan prices, renewal terms, purchase confirmation, policies, and restore purchases.

Pages shows up to three of the selected page's tags and a count for additional labels. The optional Edit tags sheet contains full-row checkmark controls, including custom AI tags. Removing a custom tag keeps it available until the sheet closes so the change can be reversed. Notes and tag corrections use the existing automatic save; tag search and Insights continue using the saved labels.

New copy is translated in English, Spanish, US Spanish, Latin American Spanish, and Arabic. Benefit icons scale with text, and accessibility text sizes use stacked theme previews. Long tag labels are constrained to the available row width.

Capture sessions explicitly apply their requested locale to SwiftUI. Custom StoreKit marketing content and its information sheet retain that app locale independently of StoreKit's commerce locale. The localized UI test asserts the translated heading as well as plan selection. The capture-session override is limited to DEBUG.

## Verification

- Bitrig builds succeeded for iOS Simulator, macOS, and visionOS Simulator with Swift 6.4 and the 27.0 SDKs.
- Inspected the phone and iPad paywalls, the information sheet, and Pages in Bitrig. Tag selection also succeeded by tapping the full row in an isolated fictional journal.
- Five native UI workflows passed across the final relevant runs: verified purchase dismissal, pending purchase approval, opening and closing the information sheet, selecting every plan in Spanish and Arabic, and tag correction surviving tab changes without Save.
- Fifteen relevant unit and rendering tests passed: five PageViewModel tests, eight journal autosave tests, and two store rendering tests. The rendering tests cover 32 theme/benefit images across all palettes, light/dark appearance, and large text; large benefit layouts also use Arabic and right-to-left layout. Inspected the rendered images and native localized paywall captures.
- TestFactory now explicitly uses local-only in-memory stores, avoiding CloudKit initialization in persistence fixtures. Production journal configuration is unchanged.
- Vision simulator builds exclude x86_64 because the existing DotLottiePlayer simulator binary only includes arm64. Both Debug and Release use this simulator-only setting; device architectures are unchanged.

StoreKit UI tests use the local test catalog with the live product identifiers and display names. This verification does not upload a build or repeat physical-device purchases or iCloud synchronization tests.
