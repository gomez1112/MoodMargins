#!/bin/zsh
set -eu
project_root="${0:A:h:h:h}"
check_dir=$(mktemp -d "${TMPDIR:-/private/tmp}/MoodMarginsWatchChecks.XXXXXX")
trap 'rm -rf "$check_dir"' EXIT
cp -R "$project_root/QA/WatchAutosaveHarness/." "$check_dir/"
mkdir -p "$check_dir/Sources/WatchJournalModel"
for name in WatchJournalStore WatchJournalEntry WatchJournalDraft; do
    cp "$project_root/WatchMoodMargins Watch App/$name.swift" "$check_dir/Sources/WatchJournalModel/"
done
cp "$project_root/MoodMargins/Shared/Model/Mood.swift" "$check_dir/Sources/WatchJournalModel/"
SWIFTPM_MODULECACHE_OVERRIDE="$check_dir/.module-cache" CLANG_MODULE_CACHE_PATH="$check_dir/.module-cache" xcrun swift test --package-path "$check_dir" --scratch-path "$check_dir/.build" --cache-path "$check_dir/.cache" --config-path "$check_dir/.config" --security-path "$check_dir/.security"
