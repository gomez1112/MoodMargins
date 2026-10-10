#!/bin/zsh
set -eu
# Pass the existing dotlottie-ios package checkout, already resolved by Bitrig.
project_root="${0:A:h:h:h}"
renderer_root="$1/Sources/DotLottieCore"
export_dir=$(mktemp -d "${TMPDIR:-/private/tmp}/MoodMarginsWatchFrames.XXXXXX")
trap 'rm -rf "$export_dir"' EXIT
player_path="$renderer_root/DotLottiePlayer.xcframework/macos-arm64_x86_64"
wgpu_path="$renderer_root/WgpuNative.xcframework/macos-arm64_x86_64"
xcrun swiftc -parse-as-library -module-cache-path "$export_dir/ModuleCache" \
    "$project_root/Tools/Assets/ExportWatchMoodFrames.swift" \
    -F "$player_path" -framework DotLottiePlayer \
    -Xlinker -rpath -Xlinker "$player_path" \
    -Xlinker -rpath -Xlinker "$wgpu_path" \
    -o "$export_dir/ExportWatchMoodFrames"
"$export_dir/ExportWatchMoodFrames" "$project_root"
