# Native Watch experience — October 11, 2026

The Watch app was completely redesigned around a direct check-in. Today contains a horizontal carousel of the five bundled animated emotions, a clear selected-state badge, and native one-tap note entry. Swiping previews a mood; tapping confirms and saves it. Both controls fit together on the 42 mm and 46 mm simulators. Native inline navigation and a plum-to-indigo canvas give the content more room.

Recent Pages uses compact native List rows with circular mood stickers, dates, and note excerpts. A separate detail view places a smaller sticker beside the mood title and gives the note the remaining space. The full-screen paper cards and separate mood-selection sheet were removed. Today and Recent Pages retain the native vertical page navigation and Crown scrolling.

The shared palette supplies cream, blush, sky, and lavender stickers against the darker canvas. SwiftUI text retains Dynamic Type and the mood buttons provide localized labels and selected traits. Reduce Motion disables transition animation. Only the focused mood animates; playback pauses for dimmed displays, inactive scenes, and disappeared views. Notes and history remain privacy-sensitive.

Mood selection saves immediately. Notes retain the existing debounce and lifecycle saves; no app Save button or save-status copy was added. Errors remain visible. Version 1.0 kept Watch entries local. Release 1.1 adds automatic private-iCloud journal sync using the shared SwiftData models, preserving existing Watch history. Premium-theme transfer remains separate from journal syncing.

## Verification

- The final companion and embedded Watch distribution build uploaded successfully as iOS 9 and passed Apple's processing as VALID.
- Four isolated Swift Testing model tests passed: explicit mood creation, stable entry identity and reopening, cancellation followed by lifecycle save, and protection of unreadable storage.
- On the 42 mm simulator, swiped the horizontal carousel, selected Laughing, and observed the native note keyboard opening. Automated text injection could not verify committing text through the system keyboard; model-level note persistence is covered by the tests.
- Inspected Today, history, and detail on 42 mm and 46 mm simulators, and captured six native images in English, Spanish, and Arabic.
- Marketing capture mode uses fictional entries and does not write to the normal journal.

The 178 transparent mood frames are exported from the exact five bundled Lottie files used by the main app and play at 15 fps. Regenerate them with `zsh Tools/Assets/ExportWatchMoodFrames.sh <existing-dotlottie-ios-checkout>`. No new dependency or UIKit bridge was added.
