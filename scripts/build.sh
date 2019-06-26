#!/bin/bash -l

set +x
set -Eeuo pipefail

rm -rf build/output
mkdir -p build/output/sim

CRITEO_ARCHS='armv7 armv7k armv7s arm64'
CRITEO_SIM_ARCHS='i386 x86_64'

CRITEO_CONFIGURATION="Release"

    # We still have to build pubsdk scheme for testing
    xcodebuild \
    -workspace fuji.xcworkspace \
        -scheme pubsdk \
        -configuration $CRITEO_CONFIGURATION \
        -IDEBuildOperationMaxNumberOfConcurrentCompileTasks=`sysctl -n hw.ncpu` \
        -derivedDataPath build/DerivedData  \
        -sdk iphonesimulator \
        -destination 'platform=iOS Simulator,name=iPhone XS,OS=latest' \
        ARCHS="$CRITEO_SIM_ARCHS" \
        VALID_ARCHS="$CRITEO_SIM_ARCHS" \
        ONLY_ACTIVE_ARCH=NO \
        clean build test | xcpretty

    xcodebuild \
    -workspace fuji.xcworkspace \
        -scheme CriteoPublisherSdk \
        -configuration $CRITEO_CONFIGURATION \
        -IDEBuildOperationMaxNumberOfConcurrentCompileTasks=`sysctl -n hw.ncpu` \
        -derivedDataPath build/DerivedData  \
        -sdk iphonesimulator \
        -destination 'platform=iOS Simulator,name=iPhone XS,OS=latest' \
        ARCHS="$CRITEO_SIM_ARCHS" \
        VALID_ARCHS="$CRITEO_SIM_ARCHS" \
        ONLY_ACTIVE_ARCH=NO \
        clean build | xcpretty

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
        build | xcpretty

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

    xcodebuild \
    -workspace fuji.xcworkspace \
        -scheme CriteoPublisherSdk \
        -configuration $CRITEO_CONFIGURATION \
        -IDEBuildOperationMaxNumberOfConcurrentCompileTasks=`sysctl -n hw.ncpu` \
        -derivedDataPath build/DerivedData  \
        -sdk iphonesimulator \
        -destination 'platform=iOS Simulator,name=iPhone XS,OS=latest' \
        ARCHS="$CRITEO_SIM_ARCHS" \
        VALID_ARCHS="$CRITEO_SIM_ARCHS" \
        ONLY_ACTIVE_ARCH=NO \
        clean build | xcpretty --report junit --report html

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
        build | xcpretty

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
