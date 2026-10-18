#!/bin/sh
set -eu

# SwiftPM copies these resource-only bundles without signing them on macOS.
# Sign them before Xcode seals the app. Archive exports re-sign the app but
# leave resource bundles alone, so archives must use the distribution identity.
# Apple rejected the unsigned copies with App Store validation error 90284.
# The Mac Release configuration permits this signing phase to use codesign
# outside Xcode's user-script sandbox; the app's sandbox remains enabled.
if [ "${PLATFORM_NAME:-}" != "macosx" ] || [ "${CONFIGURATION:-}" != "Release" ] || [ "${CODE_SIGNING_ALLOWED:-YES}" = "NO" ]; then
    exit 0
fi

signing_identity="${EXPANDED_CODE_SIGN_IDENTITY:-}"
if [ "${ACTION:-}" = "install" ]; then
    signing_identity="${MOODMARGINS_DISTRIBUTION_SIGNING_IDENTITY:-}"
fi
if [ -z "${signing_identity}" ]; then
    echo "error: The Mac resource bundles require the app's signing identity." >&2
    exit 1
fi

resource_directory="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
for product in KickstartSignal KickstartExchange; do
    resource_bundle="${resource_directory}/KickstartSDK_${product}.bundle"
    if [ ! -d "${resource_bundle}" ]; then
        echo "error: Missing ${product} resource bundle in the Mac app." >&2
        exit 1
    fi
    /usr/bin/codesign --force --sign "${signing_identity}" --timestamp=none "${resource_bundle}"
    /usr/bin/codesign --verify --strict "${resource_bundle}"
done
