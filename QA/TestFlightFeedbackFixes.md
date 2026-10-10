# TestFlight feedback fixes — October 10, 2026

The October 5 feedback reported disappearing generated tags and a subscription screen that stayed open. The attached screenshots also showed diagnostic numbers over animated moods and incorrect singular tag wording.

## Changes

- Today preserves the remaining AI suggestions when autosave refreshes the saved page. It filters newly selected tags and invalidates suggestions when the note changes or the page is deleted.
- Plus dismisses after a verified purchase grants current subscription access. It also dismisses when restored access or approval of a pending purchase unlocks Plus. A dismissal guard prevents the purchase callback and entitlement observer from popping navigation twice. Selecting a billing plan leaves the screen open for purchase confirmation.
- The existing DotLottie renderer disables the Metal HUD on its own Metal layers. The screenshot numbers appear consistent with this diagnostic overlay. This uses Apple's documented [Metal HUD configuration](https://developer.apple.com/documentation/xcode/customizing-metal-performance-hud) through DotLottie's existing renderer configuration hook.
- The journal status uses tag-count plurals in English, Spanish (including regional variants), and Arabic. Arabic includes all six plural categories.

## Validation

- `bitrig build -destination selected`: passed on the iOS 27 simulator, using Apple Swift 6.4 and Swift 6 app language mode.
- All 75 unit/regression tests passed, including successive tag selections through persistence and query refresh, external note/tag changes, deletion, all three verified subscription plans, incomplete purchase results, and localized plurals.
- Both native StoreKit UI tests passed on iPhone 18 Pro / iOS 27: successful purchase returns to Customize with active access; Ask to Buy remains open while pending and dismisses after approval.
- Inspected Today in Bitrig's iPhone 18 Pro Max simulator: all five animated mood icons were visible without numeric overlays.
- StoreKit tests use a local configuration included only in test bundles and a fictional journal for UI tests. The configuration is not attached to the production scheme or included in the shipped app.
- The UI test run emitted an unlocalized SwiftUI frame-dimension warning without a source location. Both complete workflows passed; no corresponding layout failure was observed.

The purchase UI tests exercise Apple's local StoreKit test environment. A new TestFlight build is still needed to verify the changes on a tester's device, including that device's Graphics HUD setting. Tester screenshots and journal text are not included in this report or repository.
