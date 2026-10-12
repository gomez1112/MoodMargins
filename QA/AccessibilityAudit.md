# Accessibility audit

Updated October 12, 2026 for the iOS, iPadOS, macOS, visionOS, and watchOS app targets.

## App Store Connect declarations

Five accessibility declarations were created for app `6819079849`. Each is saved as a draft. The App Store Connect version records for iOS, macOS, and visionOS are all `PREPARE_FOR_SUBMISSION`; Apple only allows publishing these labels after a version is live.

| Device family | Declaration ID | VoiceOver | Voice Control | Larger Text | Contrast | Dark | Differentiate without color | Reduced Motion | Captions / Audio Descriptions |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| iPhone | `29462f69-298b-49f8-8a9c-3a33dbde1d80` | Yes | Yes | Yes | Yes | Yes | Yes | Yes | No / No |
| iPad | `b245fd85-38a1-42f2-af9d-869bd4f10428` | Yes | Yes | Yes | Yes | Yes | Yes | Yes | No / No |
| Mac | `b83d764c-9778-4ebe-8798-4cf9053caf46` | Yes | Yes | N/A | Yes | Yes | Yes | Yes | No / No |
| Apple Watch | `271d47ca-5c8d-44a6-bcc6-e1cd94573529` | Yes | N/A | Yes | Yes | Yes | Yes | Yes | No / No |
| Apple Vision | `4049c96b-ab45-4030-8508-9ffbe5d98d66` | Yes | Yes | Yes | Yes | Yes | Yes | Yes | No / No |

Mac Larger Text and Apple Watch Voice Control are omitted from their declarations because Apple does not support those attributes for those device families. Captions and audio descriptions are marked unsupported because the app contains no video or audio media.

## Changes in the app

- Removed subdued text opacity from journal writing, section headings, recent notes, and insight recaps; long page tags now wrap at larger text sizes.
- Added headings and preserved semantic labels and selected states for mood controls, page filters, calendar entries, and chart points. The mood trend's connecting line now uses full theme ink for stronger contrast.
- Added high-contrast color variants for theme ink and actions on iPhone, iPad, Mac, and Vision. The Watch selection accent uses a darker color with stronger contrast against its paper cards.
- Kept motion-sensitive content still when Reduce Motion is enabled. This includes Lottie playback, Watch animation timelines, and animated transitions in Today.
- Preserved non-color cues: text mood names, selected-state traits, checkmarks, and chart point dates and mood values. Decorative animated emoji remain hidden from VoiceOver where a separate accessible label is provided.
- Kept the Watch journal field and mood controls as native SwiftUI controls with scalable system text.

## Verification and limits

- `bitrig build -destination all` succeeded for iOS Simulator, watchOS Simulator, visionOS Simulator, and macOS. The build emitted only the standard App Intents metadata-extraction warning because the app does not link `AppIntents.framework`.
- Inspected iPhone Today, Pages, and Insights at the largest accessibility text preset. Inspected iPad Today in dark appearance with increased contrast and the largest accessibility text preset. The content reflowed into readable, scrollable layouts.
- Inspected the Watch screen and its accessibility tree. Mood buttons expose their names and selected state, and the journal field exposes its label. The built-in Watch simulator does not expose text-size or increased-contrast settings, so those settings were not visually exercised there.
- Mac and Vision targets compiled successfully. Bitrig's built-in simulator does not run Mac or Vision apps, so runtime interaction was not verified on those targets.
- Simulator accessibility trees were checked for semantic labels, headings, values, and selected states; spoken VoiceOver and Voice Control sessions were not performed on physical devices.
