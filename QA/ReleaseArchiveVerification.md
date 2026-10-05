# TestFlight compiler fix verification

Verified October 4, 2026 for `com.transfinite.MoodMargins`, version 1.0, using Xcode 27.0 (27A266a), Swift 6.4, and the installed 27.0 platform SDKs.

The visionOS archive was compiling an unused FlexStore product whose purchase method is unavailable on visionOS. The app already implements purchases with native StoreKit `ProductView`, `SubscriptionStoreView`, and its own transaction handling, so FlexStore was removed from the project and resolved package graph.

The dotLottie dependency is now pinned to the published [0.16.9 release](https://github.com/LottieFiles/dotlottie-ios/releases/tag/v0.16.9), revision `ddc69d0ae3a90894b15b5a925c73232ff1d94307`. Its gesture implementation includes visionOS, and its UIKit player obtains display scale from the view's trait collection instead of `UIScreen`. The app continues to use its existing Metal-backed player.

After the dependency fixes, the visionOS compiler exposed additional app-level incompatibilities. Today and Pages apply scroll keyboard dismissal on iOS/macOS only; the editor's keyboard toolbar is iOS-only; theme products use StoreKit's default style on visionOS, retaining the compact style on iOS/macOS. Platform support and all 27.0 deployment targets are preserved. No older-OS availability branches were added.

| Check | Result |
| --- | --- |
| Release archive, generic visionOS device | Passed |
| Release archive, generic iOS device, including Watch companion | Passed |
| Release archive, generic macOS destination | Passed |
| Bitrig build of configured simulator and Mac targets | Passed, no diagnostics |
| Existing native Mac Lottie capture test | 1 test passed; bundled animations loaded in Today, Pages, and light/dark Insights |

Each release check used `xcodebuild archive`, the `MoodMargins` scheme, `-configuration Release`, `-disableAutomaticPackageResolution`, and `CODE_SIGNING_ALLOWED=NO`. These verify compilation, linking, and archive assembly; distribution signing and App Store Connect upload are performed when retrying the TestFlight upload in Bitrig. Release entitlements and signing settings were not changed.

Local evidence:

- `/private/tmp/mood-vision-release-archive-final.log`
- `/private/tmp/mood-ios-release-archive.log`
- `/private/tmp/mood-mac-release-archive.log`
- `/private/tmp/mood-lottie-regression.log`

The generated archives' `Info.plist` files all identify `com.transfinite.MoodMargins` version 1.0. Archives are verification artifacts outside the checkout and are not committed.
