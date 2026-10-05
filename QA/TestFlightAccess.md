# TestFlight access verification

Verified October 5, 2026 for MoodMargins (`com.transfinite.MoodMargins`, App Store Connect app `6819079849`).

Successful upload and `VALID` processing did not initially make the app installable: the builds' internal distribution state was `MISSING_EXPORT_COMPLIANCE`. The existing Internal Testing group already had access to all builds, and the existing tester was a member but remained `NOT_INVITED`.

Inspection found no application encryption implementation. CloudKit, Private Cloud Compute, StoreKit, and system network services provide the app's protected communications. The resolved Swift dependencies contain no custom encryption implementation; dotLottie's Rust ZIP dependency disables default features and enables only deflate, while its Swift networking uses URLSession. Based on this implementation and [Apple's export-compliance guidance](https://developer.apple.com/documentation/security/complying-with-encryption-export-regulations), the app uses only exempt system encryption.

`MoodMargins/Info.plist` now declares the Boolean `ITSAppUsesNonExemptEncryption = false`. The shared plist is used by the iOS, macOS, and visionOS app configurations. Bitrig's build passed with no diagnostics, and inspection of the generated iPhone simulator and Mac app plists confirmed that the value remains a Boolean false in the built products. Reassess this declaration if the app later adds its own encryption or an SDK that implements encryption.

The existing uploaded builds were updated through Apple's build API with `usesNonExemptEncryption = false`; no replacement uploads were needed to remove the hold. Apple confirmed these results:

| Platform | Version | Build | Build ID | Processing | Internal distribution |
| --- | --- | --- | --- | --- | --- |
| iOS, including Watch | 1.0 | 6 | `8c8b49e1-62fb-4c24-b80f-69e0f1f013de` | `VALID` | `IN_BETA_TESTING` |
| macOS | 1.0 | 8 | `3256443b-6523-4874-ab63-ec0d4a9f0241` | `VALID` | `IN_BETA_TESTING` |
| visionOS | 1.0 | 5 | `92dd4501-a987-49f8-98e3-296d96264a12` | `VALID` | `IN_BETA_TESTING` |

Clearing the hold activated Apple's existing invitation; the tester state changed to `INVITED` without a separate invitation request. The tester must open Apple's invitation on their device and accept it in TestFlight. No external testing review or App Store review was submitted.

For future uploads, verify both processing and internal distribution state, plus tester membership and invitation acceptance. `VALID` alone confirms processing, not TestFlight installation access.
