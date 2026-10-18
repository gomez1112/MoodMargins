# Mac resource-bundle signing

## Failure and correction

Apple rejected macOS 1.1 builds 12 and 13 with error 90284 for the Kickstart Signal and Exchange resource bundles. SwiftPM's original copies were unsigned. Signing them with the normal archive development identity was insufficient: distribution export re-signs the app, but leaves these resource bundles with a certificate that does not match the App Store profile.

The app target now runs `Tools/Distribution/SignMacResourceBundles.sh` after copying resources and before Xcode signs the outer app. It affects Mac Release builds only. Ordinary builds use `EXPANDED_CODE_SIGN_IDENTITY`; archive actions (`ACTION=install`) use `MOODMARGINS_DISTRIBUTION_SIGNING_IDENTITY`, set to the existing Apple Distribution identity for team 88QL9VPLMY. Missing bundles, unavailable identities, and failed signatures stop the build. The SDK sources, dependencies, resources, premium behavior, and runtime identifiers are unchanged.

Xcode's user-script sandbox is disabled only for the main app's Mac Release configuration because codesign cannot sign these bundles within that script sandbox. The app's sandbox and hardened runtime remain enabled. Resource bundles are signed individually; recursive signing with `--deep` is not used. This follows [Apple's guidance on signing nested content before sealing its parent](https://developer.apple.com/library/archive/technotes/tn2206/_index.html#//apple_ref/doc/uid/DTS40007919-CH1-TNTAG12).

## Verification on October 18, 2026

- `bitrig build -scheme MoodMargins -configuration Release -destination 'generic/platform=macOS'` succeeded after enabling codesign access for the phase.
- The resulting app passed `codesign --verify --deep --strict`, run outside the restricted command shell so the system trust service was accessible.
- An isolated archive-mode check supplied a development identity to the script and verified that both bundles instead used the intended distribution certificate. Their signatures passed strict verification.
- The public certificate extracted from each signed fixture matched a certificate embedded in the actual active Mac App Store provisioning profile, decoded from Apple's profile response.
- `bitrig preview -platform macOS -configuration Release` reported that no Mac preview was selected, so it did not launch the app.

Build 14 is the replacement archive with the distribution-identity correction. Apple processed it as VALID, and macOS version 1.1 and its review submission both report WAITING_FOR_REVIEW. The final build ID is `9297cb28-b5fa-489c-83f8-4dd6ac424e36`. The upload tool's completion message alone does not prove Apple's server accepted a build; the final server state was verified separately. See `Marketing/ReleaseReadiness.md` for the submission receipt.

When renewing distribution certificates, ensure the named identity and the Mac App Store profile still match. No signing key, password, or private certificate material is stored in this repository.
