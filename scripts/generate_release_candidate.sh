#!/bin/bash -l

set +x
set -Eeuo pipefail

# ----To be updated for each RC---------
# For naming the frameworks
SDK_VERSION_NUMBER="3.4.0-rc2"
# For getting the frameworks on Jenkins
SDK_BUILD_NUMBER="1354"
# For inserting the CFBundleShortVersionString to the testing app
TEST_APP_VERSION_NUMBER="1.3.0"
# For inserting the CFBundleVersion to the testing app
TEST_APP_BUILD_NUMBER="69"
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
cd "$SDK_DEBUG_DIR_IN_APP/AdViewer"
TEST_APP_INFOPLIST_FILE="Info.plist"
TEST_APP_PREVIOUS_VERSION_NUMBER=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$TEST_APP_INFOPLIST_FILE")
TEST_APP_PREVIOUS_BUILD_NUMBER=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$TEST_APP_INFOPLIST_FILE")
/usr/libexec/PlistBuddy -c "Set CFBundleShortVersionString ${TEST_APP_VERSION_NUMBER}" "$TEST_APP_INFOPLIST_FILE"
/usr/libexec/PlistBuddy -c "Set CFBundleVersion ${TEST_APP_BUILD_NUMBER}" "$TEST_APP_INFOPLIST_FILE"
echo -e "\t> CFBundleShortVersionString changed from ${TEST_APP_PREVIOUS_VERSION_NUMBER} to ${TEST_APP_VERSION_NUMBER}" 
echo -e "\t> CFBundleVersion changed from ${TEST_APP_PREVIOUS_BUILD_NUMBER} to ${TEST_APP_BUILD_NUMBER}" 
cd ../../
pod install
xed fuji-test-app.xcworkspace
open $BUILD_DIRECTORY





