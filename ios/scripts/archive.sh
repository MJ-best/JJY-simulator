#!/usr/bin/env bash
set -euo pipefail

# Build, test, archive, and export JJYSimulator for App Store Connect / TestFlight.
#
# Usage:
#   DEVELOPMENT_TEAM=YOUR_TEAM_ID ./scripts/archive.sh
#   DEVELOPMENT_TEAM=YOUR_TEAM_ID BUNDLE_ID=com.example.jjysimulator MARKETING_VERSION=1.0 BUILD_NUMBER=1 ./scripts/archive.sh
#   DEVELOPMENT_TEAM=YOUR_TEAM_ID ./scripts/archive.sh --upload

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IOS_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PROJECT="${IOS_DIR}/JJYSimulator.xcodeproj"
SCHEME="JJYSimulator"
BUILD_DIR="${IOS_DIR}/build"
ARCHIVE_PATH="${BUILD_DIR}/JJYSimulator.xcarchive"
EXPORT_PATH="${BUILD_DIR}/export"
EXPORT_OPTIONS="${IOS_DIR}/ExportOptions.plist"

DEVELOPMENT_TEAM="${DEVELOPMENT_TEAM:-}"
BUNDLE_ID="${BUNDLE_ID:-com.mjbest.jjysimulator}"
MARKETING_VERSION="${MARKETING_VERSION:-1.0}"
BUILD_NUMBER="${BUILD_NUMBER:-1}"
UPLOAD_FLAG="${1:-}"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Error: archive.sh must be run on macOS with Xcode installed." >&2
  exit 1
fi

if [[ -z "${DEVELOPMENT_TEAM}" ]]; then
  echo "Error: Set DEVELOPMENT_TEAM to your 10-character Apple Developer Team ID." >&2
  echo "Example: DEVELOPMENT_TEAM=ABCDE12345 ./scripts/archive.sh" >&2
  exit 1
fi

mkdir -p "${BUILD_DIR}"

echo "==> 1/3 Running unit tests..."
xcodebuild test \
  -project "${PROJECT}" \
  -scheme "${SCHEME}" \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=latest" \
  CODE_SIGNING_ALLOWED=NO

echo "==> 2/3 Archiving Release build (${MARKETING_VERSION} / build ${BUILD_NUMBER})..."
rm -rf "${ARCHIVE_PATH}" "${EXPORT_PATH}"
xcodebuild archive \
  -project "${PROJECT}" \
  -scheme "${SCHEME}" \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "${ARCHIVE_PATH}" \
  DEVELOPMENT_TEAM="${DEVELOPMENT_TEAM}" \
  PRODUCT_BUNDLE_IDENTIFIER="${BUNDLE_ID}" \
  MARKETING_VERSION="${MARKETING_VERSION}" \
  CURRENT_PROJECT_VERSION="${BUILD_NUMBER}" \
  -allowProvisioningUpdates

echo "==> 3/3 Exporting App Store IPA..."
TMP_EXPORT_OPTIONS="${BUILD_DIR}/ExportOptions.generated.plist"
cp "${EXPORT_OPTIONS}" "${TMP_EXPORT_OPTIONS}"
/usr/libexec/PlistBuddy -c "Delete :teamID" "${TMP_EXPORT_OPTIONS}" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :teamID string ${DEVELOPMENT_TEAM}" "${TMP_EXPORT_OPTIONS}"
if [[ "${UPLOAD_FLAG}" == "--upload" ]]; then
  /usr/libexec/PlistBuddy -c "Set :destination upload" "${TMP_EXPORT_OPTIONS}"
fi

xcodebuild -exportArchive \
  -archivePath "${ARCHIVE_PATH}" \
  -exportPath "${EXPORT_PATH}" \
  -exportOptionsPlist "${TMP_EXPORT_OPTIONS}" \
  -allowProvisioningUpdates

echo ""
echo "Done!"
echo "  Archive: ${ARCHIVE_PATH}"
if [[ "${UPLOAD_FLAG}" == "--upload" ]]; then
  echo "  Uploaded to App Store Connect (check TestFlight in a few minutes)."
else
  echo "  Exported IPA: ${EXPORT_PATH}"
  echo "  To upload via Xcode Organizer: open \"${ARCHIVE_PATH}\""
  echo "  Or re-run with --upload to upload directly via xcodebuild."
fi
