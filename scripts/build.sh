#!/bin/bash -l

set +x
set -Eeuo pipefail

rm -rf build/output
mkdir -p build/output/sim

export LANG=en_US.UTF-8

CRITEO_WATCH_ARCHS='armv7k arm64_32'
CRITEO_DEVICE_ARCHS='armv7 armv7s arm64'
CRITEO_ARCHS="$CRITEO_DEVICE_ARCHS $CRITEO_WATCH_ARCHS"
CRITEO_SIM_ARCHS='i386 x86_64'

XCODEBUILD_LOG=build/output/xcodebuild.log

# Configuration for compiling the project for the simulator.
# For now, we set a fixed OS version instead of the "latest"
# The goal is produce the same output from any machine
# (whether you have updated your xcode or not).
XCODEBUILD_DESTINATION_SIMULATOR_OS="12.4"
XCODEBUILD_DESTINATION_SIMULATOR_DEVICE="iPhone Xs"
XCODEBUILD_DESTINATION_SIMULATOR_NAME="Fuji PreSubmit Tests Simulator"
XCODEBUILD_DESTINATION_SIMULATOR="platform=iOS Simulator,name=${XCODEBUILD_DESTINATION_SIMULATOR_NAME},OS=${XCODEBUILD_DESTINATION_SIMULATOR_OS}"


if [ $# -eq 0 ]; then
    XCODEBUILD_SCHEME_FOR_TESTING="pubsdk"
else
    XCODEBUILD_SCHEME_FOR_TESTING="$1"
fi
echo "Selected SCHEME for testing: ${XCODEBUILD_SCHEME_FOR_TESTING}"

# Delete the left over simulators from previous xcode version
xcrun simctl delete unavailable

# Get the identifier of the selected simulator runtime
SIMULATOR_RUNTIME_AVAILABLE=$(xcrun simctl list runtimes | grep iOS | grep "${XCODEBUILD_DESTINATION_SIMULATOR_OS}" | awk '{print $NF}' || true)
if [ -z "$SIMULATOR_RUNTIME_AVAILABLE" ]; then
    echo "[ERROR] The selected simulator runtime ${XCODEBUILD_DESTINATION_SIMULATOR_OS}"
    echo "Available simulator runtime:"
    xcrun simctl list runtimes
    exit 1
else
    echo "Runtime identifier for ${XCODEBUILD_DESTINATION_SIMULATOR_OS}: ${SIMULATOR_RUNTIME_AVAILABLE}"
fi

# Get the identifier of the selected simulator device
SIMULATOR_DEVICE_TYPE_AVAILABLE=$(xcrun simctl list devicetypes | grep --ignore-case "${XCODEBUILD_DESTINATION_SIMULATOR_DEVICE}" | head -n 1 | cut -f2 -d'(' | cut -f1 -d')' || true)
if [ -z "$SIMULATOR_DEVICE_TYPE_AVAILABLE" ]; then
    echo "[ERROR] The selected simulator devicetype ${XCODEBUILD_DESTINATION_SIMULATOR_DEVICE}"
    echo 'Available devicetypes:'
    xcrun simctl list devicetypes
    exit 1
else
    echo "Runtime identifier for ${XCODEBUILD_DESTINATION_SIMULATOR_DEVICE}: ${SIMULATOR_DEVICE_TYPE_AVAILABLE}"
fi

# Delete and re-create the simulator device to ensure isolation
printf "Deleting the previous test run simulator...\n"
xcrun simctl delete \
    "${XCODEBUILD_DESTINATION_SIMULATOR_NAME}" \
    || true
printf "Creating the simulator ${XCODEBUILD_DESTINATION_SIMULATOR_NAME}...\n"
xcrun simctl create \
    "${XCODEBUILD_DESTINATION_SIMULATOR_NAME}"  \
    $SIMULATOR_DEVICE_TYPE_AVAILABLE \
    $SIMULATOR_RUNTIME_AVAILABLE

pod install

CRITEO_CONFIGURATION="Release"
printf "Launching $CRITEO_CONFIGURATION build\nARCHS: $CRITEO_ARCHS\nSIM ARCHS: $CRITEO_SIM_ARCHS\n"

if [ "$XCODEBUILD_SCHEME_FOR_TESTING" != skipTests ]; then
    # We still have to build scheme for testing
    xcodebuild \
    -workspace fuji.xcworkspace \
        -scheme "${XCODEBUILD_SCHEME_FOR_TESTING}" \
        -configuration $CRITEO_CONFIGURATION \
        -IDEBuildOperationMaxNumberOfConcurrentCompileTasks=`sysctl -n hw.ncpu` \
        -derivedDataPath build/DerivedData  \
        -sdk iphonesimulator \
        -destination "${XCODEBUILD_DESTINATION_SIMULATOR}" \
        ARCHS="$CRITEO_SIM_ARCHS" \
        VALID_ARCHS="$CRITEO_SIM_ARCHS" \
        ONLY_ACTIVE_ARCH=NO \
        clean build test | tee -a $XCODEBUILD_LOG | xcpretty --report junit --report html
fi

    xcodebuild \
    -workspace fuji.xcworkspace \
        -scheme CriteoPublisherSdk \
        -configuration $CRITEO_CONFIGURATION \
        -IDEBuildOperationMaxNumberOfConcurrentCompileTasks=`sysctl -n hw.ncpu` \
        -derivedDataPath build/DerivedData  \
        -sdk iphonesimulator \
        -destination "${XCODEBUILD_DESTINATION_SIMULATOR}" \
        ARCHS="$CRITEO_SIM_ARCHS" \
        VALID_ARCHS="$CRITEO_SIM_ARCHS" \
        ONLY_ACTIVE_ARCH=NO \
        clean build | tee -a $XCODEBUILD_LOG | xcpretty

        cp -R "build/DerivedData/Build/Products/$CRITEO_CONFIGURATION-iphonesimulator/CriteoPublisherSdk.framework" build/output/sim

        mkdir -p build/output/device

    xcodebuild \
    -workspace fuji.xcworkspace \
        -scheme CriteoPublisherSdk \
        -configuration $CRITEO_CONFIGURATION \
        -IDEBuildOperationMaxNumberOfConcurrentCompileTasks=`sysctl -n hw.ncpu` \
        -derivedDataPath build/DerivedData  \
        -sdk iphoneos \
        ARCHS="$CRITEO_ARCHS" \
        VALID_ARCHS="$CRITEO_ARCHS" \
        ONLY_ACTIVE_ARCH=NO \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        OTHER_CFLAGS="-fembed-bitcode" \
        build | tee -a $XCODEBUILD_LOG | xcpretty

        cp -R "build/DerivedData/Build/Products/$CRITEO_CONFIGURATION-iphoneos/CriteoPublisherSdk.framework" build/output/device

cp -R build/output/device/CriteoPublisherSdk.framework build/output
rm build/output/CriteoPublisherSdk.framework/CriteoPublisherSdk

lipo -create -output build/output/CriteoPublisherSdk.framework/CriteoPublisherSdk build/output/sim/CriteoPublisherSdk.framework/CriteoPublisherSdk build/output/device/CriteoPublisherSdk.framework/CriteoPublisherSdk
echo "Fat Binary Contents for $CRITEO_CONFIGURATION Build:"
echo "----------------------------------------------------"
objdump -macho -universal-headers -arch all build/output/CriteoPublisherSdk.framework/CriteoPublisherSdk
echo "----------------------------------------------------"

cd build/output

zip -r "CriteoPublisherSdk.framework.$CRITEO_CONFIGURATION.zip" CriteoPublisherSdk.framework

cd ../..


CRITEO_CONFIGURATION="Debug"
printf "Launching $CRITEO_CONFIGURATION build\nARCHS: $CRITEO_ARCHS\nSIM ARCHS: $CRITEO_SIM_ARCHS\n"

    xcodebuild \
    -workspace fuji.xcworkspace \
        -scheme CriteoPublisherSdk \
        -configuration $CRITEO_CONFIGURATION \
        -IDEBuildOperationMaxNumberOfConcurrentCompileTasks=`sysctl -n hw.ncpu` \
        -derivedDataPath build/DerivedData  \
        -sdk iphonesimulator \
        -destination "${XCODEBUILD_DESTINATION_SIMULATOR}" \
        ARCHS="$CRITEO_SIM_ARCHS" \
        VALID_ARCHS="$CRITEO_SIM_ARCHS" \
        ONLY_ACTIVE_ARCH=NO \
        clean build | tee -a $XCODEBUILD_LOG | xcpretty

        cp -R "build/DerivedData/Build/Products/$CRITEO_CONFIGURATION-iphonesimulator/CriteoPublisherSdk.framework" build/output/sim

        mkdir -p build/output/device

    xcodebuild \
    -workspace fuji.xcworkspace \
        -scheme CriteoPublisherSdk \
        -configuration $CRITEO_CONFIGURATION \
        -IDEBuildOperationMaxNumberOfConcurrentCompileTasks=`sysctl -n hw.ncpu` \
        -derivedDataPath build/DerivedData  \
        -sdk iphoneos \
        ARCHS="$CRITEO_ARCHS" \
        VALID_ARCHS="$CRITEO_ARCHS" \
        ONLY_ACTIVE_ARCH=NO \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        OTHER_CFLAGS="-fembed-bitcode" \
        build | tee -a $XCODEBUILD_LOG | xcpretty

        cp -R "build/DerivedData/Build/Products/$CRITEO_CONFIGURATION-iphoneos/CriteoPublisherSdk.framework" build/output/device

cp -R build/output/device/CriteoPublisherSdk.framework build/output
rm build/output/CriteoPublisherSdk.framework/CriteoPublisherSdk

lipo -create -output build/output/CriteoPublisherSdk.framework/CriteoPublisherSdk build/output/sim/CriteoPublisherSdk.framework/CriteoPublisherSdk build/output/device/CriteoPublisherSdk.framework/CriteoPublisherSdk
echo "Fat Binary Contents for $CRITEO_CONFIGURATION Build:"
echo "----------------------------------------------------"
objdump -macho -universal-headers -arch all build/output/CriteoPublisherSdk.framework/CriteoPublisherSdk
echo "----------------------------------------------------"

cd build/output

zip -r "CriteoPublisherSdk.framework.$CRITEO_CONFIGURATION.zip" CriteoPublisherSdk.framework

cd ../..
