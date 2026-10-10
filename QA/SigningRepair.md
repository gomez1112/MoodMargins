# Distribution signing repair

Verified October 5, 2026 for team `88QL9VPLMY` (TRANSFINITE LLC).

The previous Apple Distribution key was in the separate `MorrowplateDistribution-88QL9VPLMY.keychain-db` keychain, whose password was unavailable. MoodMargins' export selected that certificate even though its existing TV provisioning profile belonged to Nourish.

The replacement private key is stored in the user's normal login keychain. Its import authorizes `/usr/bin/codesign` and Bitrig to use it. No separate keychain or generated keychain password was introduced. Temporary private-key files were deleted after import; this document contains only public signing identifiers.

| Asset | Retired | Replacement |
| --- | --- | --- |
| Apple Distribution certificate | `FGU4DMMS48` (revoked) | `3N2HX92GUQ`, expires October 5, 2027 |
| Nourish TV App Store profile | `8QHHH2L3JN` (deleted) | `52GZD85FL9`, name `Nourish Apple TV App Store` |
| Profile UUID | `0b087445-c368-4584-bab1-877e4a3c22da` | `423b302d-dbbf-480f-9fd4-5c14955fed9b` |

The new certificate's SHA-1 fingerprint is `6B932826E73EA32D0D41659A799C8A8FAEEEE4EF`. The replacement profile preserves the original team, tvOS platform, bundle identifier `app.bitrig.gerardgomez.nourish`, and every provisioning entitlement. It is active in App Store Connect and installed in Xcode's current provisioning-profile directory.

To prevent selecting the retired key again, its keychain was removed from the user's signing search list, preserving the keychain file. Only the old TV profile was removed from the local provisioning cache. Existing development certificates and all other keychains were preserved. MoodMargins retains automatic signing; no certificate ID or provisioning-profile ID was hardcoded into the project.

Validation passed: certificate trust evaluation against Apple's signing chain; repeated signing of a freshly compiled Swift fixture; strict static signature verification with normal macOS certificate-store access; matching TV profile permissions; and App Store Connect confirmation that the retired assets are absent and their replacements are active. Restricted sandbox verification initially could not access the certificate trust services; repeating the check with normal access passed without changing any certificate trust settings.

Future certificate replacements should store the private key in the login keychain, verify signing access and the replacement profile before revoking the previous certificate, and remove retired profiles from local signing discovery. This fixes selection of the inaccessible Morrowplate key; ordinary macOS prompts for a locked login keychain remain possible.

The first retry completed distribution export and upload without stalling on the retired keychain: version 1.0, iOS build 3 (including the Watch companion), macOS build 3, and visionOS build 2 reached App Store Connect. Apple then rejected processing for unrelated packaging problems: Watch icon errors `90391`/`90713`, visionOS icon error `90970`, and Mac widget profile error `90283`.

The Watch target now includes the existing `MoodMarginsIcon.icon` resource and selects it as its primary icon instead of the empty `AppIcon` set. The multiplatform app uses the same existing diary artwork in a visionOS image stack, selected through SDK-specific icon settings. Its three 1024-pixel PNG layers are exported from the original SVG artwork; the background is opaque and each layer is marked as 2×. Other platforms continue using Icon Composer.

Inspection of an actual Mac package found the root cause of the widget error: `MoodMarginsWidgetMac` contains no Swift source, and its built `.appex` contains no executable. Xcode copies that empty resource bundle and its development profile but omits it from distribution signing. The host app no longer builds or embeds this empty placeholder. The existing iOS widget and Watch companion remain configured. The temporary Mac widget profile created during diagnosis was deleted from App Store Connect and the local profile cache.

The Mac app now declares `LSApplicationCategoryType = public.app-category.lifestyle` through Mac-specific Debug and Release settings, matching its App Store category. This resolves Apple's subsequent validation error `90242`.

The corrected project passed Bitrig's build with no diagnostics. The Watch and visionOS icon sets compiled with Xcode's asset compiler without errors, generating `CFBundleIcons.CFBundlePrimaryIcon` metadata. Version 1.0 iOS build 4 and visionOS build 3 passed Apple's processing checks.

Mac build 6 completed a signed Release archive and local App Store export with the required Lifestyle category and no empty widget bundle. Inspection of the corrected local Mac export verified that the app's certificate matches its embedded App Store profile, all nested code passes strict signature verification, and the installer package has a valid Apple signature. Xcode 27's `altool --validate-app` reported `VERIFY SUCCEEDED with no errors` for build 6 before its Mac-only upload.

App Store Connect confirms all final version 1.0 builds have processing state `VALID`:

| Platform | Build | App Store Connect build ID |
| --- | --- | --- |
| iOS, including Watch | 4 | `a52ddd87-e8b6-432a-8e24-64cc5ba570d5` |
| macOS | 6 | `35dd7f32-2f68-4ff5-b3f0-c3a89c36fb92` |
| visionOS | 3 | `f7d3d2ac-c69b-41fe-a407-6f7f4a02e2f5` |

The final Bitrig build also succeeded with no diagnostics. The user keychain search list still excludes the retired keychain after distribution exports and uploads. Temporary App Store Connect authentication files were removed after use, retaining the original credentials in Keychain. No build was submitted for App Store review.
