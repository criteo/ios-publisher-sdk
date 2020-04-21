#!/bin/bash -l

set +x
set -Eeuo pipefail

# ----To be updated for each RC---------
# For naming the frameworks
SDK_VERSION_NUMBER="3.5.0-rc1"
# For getting the frameworks on Jenkins
SDK_BUILD_NUMBER="1954"
# ---------------------------------------

SCRIPT_DIRECTORY="$( cd "$(dirname "$0")" ; pwd -P )"
BUILD_DIRECTORY="${SCRIPT_DIRECTORY}/../build/release_candidate"
SDK_RELEASE_ZIP_NAME="CriteoPublisherSDK_iOS_${SDK_VERSION_NUMBER}_Release.zip"
SDK_DEBUG_ZIP_NAME="CriteoPublisherSDK_iOS_${SDK_VERSION_NUMBER}_Debug.zip"
SDK_DEBUG_DIR_IN_APP="${BUILD_DIRECTORY}/fuji-test-app/AdViewer/"

echo "Prepare the build directory"
rm -rf "$BUILD_DIRECTORY"
mkdir -p "$BUILD_DIRECTORY"
cd "$BUILD_DIRECTORY"

echo "Download the artefact for release: ${SDK_RELEASE_ZIP_NAME}"
curl -o "$SDK_RELEASE_ZIP_NAME" "https://build.crto.in/job/pub-sdk-fuji-pre-submit/${SDK_BUILD_NUMBER}/artifact/build/output/CriteoPublisherSdk.framework.Release.zip"

echo "Download the artefact for debug: ${SDK_DEBUG_ZIP_NAME}"
curl -o "$SDK_DEBUG_ZIP_NAME" "https://build.crto.in/job/pub-sdk-fuji-pre-submit/${SDK_BUILD_NUMBER}/artifact/build/output/CriteoPublisherSdk.framework.Debug.zip"

echo "Clone the testing app for creating a new version"
git clone https://review.crto.in/pub-sdk/fuji-test-app
cp "$SDK_DEBUG_ZIP_NAME" "$SDK_DEBUG_DIR_IN_APP"
unzip "$SDK_DEBUG_ZIP_NAME" -d "$SDK_DEBUG_DIR_IN_APP"
cd "$SDK_DEBUG_DIR_IN_APP/.."
pod install
xed fuji-test-app.xcworkspace
open $BUILD_DIRECTORY
