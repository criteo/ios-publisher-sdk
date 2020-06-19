#!/bin/bash -l

set +x
set -Eeuo pipefail

SCRIPT_DIRECTORY="$(
  cd "$(dirname "$0")"
  pwd -P
)"
# shellcheck source=scripts/base.sh
source "$SCRIPT_DIRECTORY"/base.sh

fuji-clean

if [ $# -eq 0 ]; then
    XCODEBUILD_SCHEME_FOR_TESTING="CriteoPublisherSdk"
else
    XCODEBUILD_SCHEME_FOR_TESTING="$1"
fi
fuji-echo "Selected SCHEME for testing: ${XCODEBUILD_SCHEME_FOR_TESTING}"

# Delete the left over simulators from previous xcode version
xcrun simctl delete unavailable

# Get the identifier of the selected simulator runtime
#SIMULATOR_RUNTIME_AVAILABLE=$(xcrun simctl list runtimes | grep iOS | grep "${XCODEBUILD_DESTINATION_SIMULATOR_OS}" | awk '{print $NF}' || true)
#if [ -z "$SIMULATOR_RUNTIME_AVAILABLE" ]; then
#    fuji-echo "[ERROR] The selected simulator runtime ${XCODEBUILD_DESTINATION_SIMULATOR_OS}"
#    fuji-echo "Available simulator runtime:"
#    xcrun simctl list runtimes
#    exit 1
#else
#    fuji-echo "Runtime identifier for ${XCODEBUILD_DESTINATION_SIMULATOR_OS}: ${SIMULATOR_RUNTIME_AVAILABLE}"
#fi

# Get the identifier of the selected simulator device
SIMULATOR_DEVICE_TYPE_AVAILABLE=$(xcrun simctl list devicetypes | grep --ignore-case "${XCODEBUILD_DESTINATION_SIMULATOR_DEVICE}" | head -n 1 | cut -f2 -d'(' | cut -f1 -d')' || true)
if [ -z "$SIMULATOR_DEVICE_TYPE_AVAILABLE" ]; then
    fuji-echo "[ERROR] The selected simulator devicetype ${XCODEBUILD_DESTINATION_SIMULATOR_DEVICE}"
    fuji-echo 'Available devicetypes:'
    xcrun simctl list devicetypes
    exit 1
else
    fuji-echo "Runtime identifier for ${XCODEBUILD_DESTINATION_SIMULATOR_DEVICE}: ${SIMULATOR_DEVICE_TYPE_AVAILABLE}"
fi

# Delete and re-create the simulator device to ensure isolation
fuji-echo "Deleting the previous test run simulator..."
xcrun simctl delete \
    "${XCODEBUILD_DESTINATION_SIMULATOR_NAME}" \
    || true
fuji-echo "Creating the simulator ${XCODEBUILD_DESTINATION_SIMULATOR_NAME}..."
xcrun simctl create \
    "${XCODEBUILD_DESTINATION_SIMULATOR_NAME}"  \
    $SIMULATOR_DEVICE_TYPE_AVAILABLE #\
#    $SIMULATOR_RUNTIME_AVAILABLE

fuji-echo "Cocoapods repo update..."
pod repo update --silent
fuji-echo "Cocoapods install..."
pod install --deployment --clean-install --no-repo-update

function fuji-test () {
    fuji-echo "$2($1)"
    xcodebuild \
        -workspace fuji.xcworkspace \
        -scheme "${XCODEBUILD_SCHEME_FOR_TESTING}" \
        -IDEBuildOperationMaxNumberOfConcurrentCompileTasks=`sysctl -n hw.ncpu` \
        -derivedDataPath build/DerivedData  \
        -sdk iphonesimulator \
        -destination "${XCODEBUILD_DESTINATION_SIMULATOR}" \
        $1 \
        ARCHS="$CRITEO_SIM_ARCHS" \
        VALID_ARCHS="$CRITEO_SIM_ARCHS" \
        ONLY_ACTIVE_ARCH=NO \
        $2
}

if [ "$XCODEBUILD_SCHEME_FOR_TESTING" != skipTests ]; then
    fuji-echo "Testing"
    fuji-test "" build-for-testing | fuji-pretty
    fuji-test "-only-testing pubsdkITests" test-without-building \
      | fuji-pretty --report junit --report html
    fuji-test "-only-testing pubsdkTests" test-without-building \
      | fuji-pretty --report junit --report html
fi

function fuji-build-simulator () {
    fuji-echo "[simulator] build($*)"
    xcodebuild \
        -workspace fuji.xcworkspace \
        -scheme CriteoPublisherSdk \
        -configuration $CRITEO_CONFIGURATION \
        -IDEBuildOperationMaxNumberOfConcurrentCompileTasks=`sysctl -n hw.ncpu` \
        -derivedDataPath build/DerivedData \
        -sdk iphonesimulator \
        -destination "${XCODEBUILD_DESTINATION_SIMULATOR}" \
        ARCHS="$CRITEO_SIM_ARCHS" \
        VALID_ARCHS="$CRITEO_SIM_ARCHS" \
        ONLY_ACTIVE_ARCH=NO \
        $*
}

function fuji-build-device () {
    fuji-echo "[device] build($*)"
    xcodebuild \
        -workspace fuji.xcworkspace \
        -scheme CriteoPublisherSdk \
        -configuration $CRITEO_CONFIGURATION \
        -IDEBuildOperationMaxNumberOfConcurrentCompileTasks=`sysctl -n hw.ncpu` \
        -derivedDataPath build/DerivedData \
        -sdk iphoneos \
        ARCHS="$CRITEO_ARCHS" \
        VALID_ARCHS="$CRITEO_ARCHS" \
        ONLY_ACTIVE_ARCH=NO \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        OTHER_CFLAGS="-fembed-bitcode" \
        $*
}

function fuji-fat-build () {
    fuji-echo "Building $CRITEO_CONFIGURATION..."

    mkdir -p build/output/simulator
    fuji-build-simulator clean build | fuji-pretty
    cp -R "build/DerivedData/Build/Products/$CRITEO_CONFIGURATION-iphonesimulator/CriteoPublisherSdk.framework" build/output/simulator

    mkdir -p build/output/device
    fuji-build-device build | fuji-pretty
    cp -R "build/DerivedData/Build/Products/$CRITEO_CONFIGURATION-iphoneos/CriteoPublisherSdk.framework" build/output/device
    cp -R build/output/device/CriteoPublisherSdk.framework build/output
    rm build/output/CriteoPublisherSdk.framework/CriteoPublisherSdk

    lipo -create -output build/output/CriteoPublisherSdk.framework/CriteoPublisherSdk build/output/simulator/CriteoPublisherSdk.framework/CriteoPublisherSdk build/output/device/CriteoPublisherSdk.framework/CriteoPublisherSdk
    fuji-echo "Fat Binary Contents for $CRITEO_CONFIGURATION Build:"
    objdump -macho -universal-headers -arch all build/output/CriteoPublisherSdk.framework/CriteoPublisherSdk
}

function fuji-archive () {
    pushd build/output
    fuji-echo "Archiving..."
    zip -r "CriteoPublisherSdk.framework.$CRITEO_CONFIGURATION.zip" CriteoPublisherSdk.framework
    popd
}

function fuji-remove-headers () {
    pushd build/output/CriteoPublisherSdk.framework/Headers
    fuji-echo "Removing public headers..."
    for header in $*; do {
        fuji-echo "Removing $header"
        sed -i '' "/$header/d" CriteoPublisherSdk.h
        rm $header
    } done
    popd
}

CRITEO_CONFIGURATION="Release"
fuji-fat-build
fuji-archive

CRITEO_CONFIGURATION="Debug"
fuji-fat-build
fuji-archive

fuji-echo "Build completed."