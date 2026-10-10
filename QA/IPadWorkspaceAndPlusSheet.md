# iPad workspace and Plus sheet — October 10, 2026

Today uses a larger writing area beside AI suggestions and two recent pages when the available window width is at least 800 points. Pages keeps the selected page beside an independently scrolling history browser. Narrow windows and accessibility text sizes use a single column. Existing automatic saves remain in place.

Plus opens as a modal from Customize, a premium theme preview, and the Today/Insights feature cards. It uses a centered form sheet on iPad, a Close control, and the native SubscriptionStoreView with a compact plan picker. Benefits, policies, billing options, Subscribe, and Restore share one scrollable surface. Detailed AI information remains in its own sheet. Large text wraps fully and scrolls to the purchase controls.

The native subscription view receives the products already loaded by PurchaseStore. Loading failures keep the benefits visible and offer retry. Purchase feedback is presented inside the Plus sheet, so pending approval does not dismiss it. Verified access or restored access still dismisses it.

## Verification

- Bitrig builds succeeded for iOS Simulator, macOS, and visionOS Simulator using the 27.0 SDKs and Swift 6.4.
- Three final iPad StoreKit workflows passed: plans and controls fit in portrait and landscape, verified purchases dismiss, and pending purchases stay open until approved.
- Five phone regression workflows passed: automatic saving, Spanish/Arabic plan selection, information-sheet presentation, verified purchases, and pending approval.
- The iPad history test verifies independent scrolling, selection without moving the editor, and automatic save persistence across tab changes.
- A separate iPad route test passed: opening and closing Plus preserves the theme preview and Today screen. Ten workflows passed across the final phone and iPad runs.
- Inspected Today and Pages in portrait and landscape, plus the sheet in light/dark appearance and accessibility text sizes. Large-text benefits wrap fully; the native billing, Subscribe, and Restore controls remain reachable by scrolling.
- UI tests use an isolated fictional journal and a local StoreKit test catalog. Production signing, catalog configuration, and CloudKit persistence are unchanged.

SwiftUI emitted an invalid-frame warning during journal focus in the autosave UI tests. Save and keyboard-dismissal assertions passed; no visible clipping was observed. Test results do not verify new physical-device purchases or cloud synchronization.
