#!/bin/bash -l

set +x
set -Eeuo pipefail

rm -rf build/output
mkdir -p build/output/sim

CRITEO_ARCHS='armv7 armv7s arm64'
CRITEO_SIM_ARCHS='i386 x86_64'

CRITEO_CONFIGURATION="Release"

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
        clean build | xcpretty

        cp -R "build/DerivedData/Build/Products/$CRITEO_CONFIGURATION-iphonesimulator/pubsdk.framework" build/output/sim

        mkdir -p build/output/device

    xcodebuild \
    -workspace fuji.xcworkspace \
        -scheme pubsdk \
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

        cp -R "build/DerivedData/Build/Products/$CRITEO_CONFIGURATION-iphoneos/pubsdk.framework" build/output/device

cp -R build/output/device/pubsdk.framework build/output
rm build/output/pubsdk.framework/pubsdk

lipo -create -output build/output/pubsdk.framework/pubsdk build/output/sim/pubsdk.framework/pubsdk build/output/device/pubsdk.framework/pubsdk

cd build/output

zip -r "pubsdk.framework.$CRITEO_CONFIGURATION.zip" pubsdk.framework

cd ../..


CRITEO_CONFIGURATION="Debug"

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
        clean build test | xcpretty --report junit --report html

        cp -R "build/DerivedData/Build/Products/$CRITEO_CONFIGURATION-iphonesimulator/pubsdk.framework" build/output/sim

        mkdir -p build/output/device

    xcodebuild \
    -workspace fuji.xcworkspace \
        -scheme pubsdk \
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

        cp -R "build/DerivedData/Build/Products/$CRITEO_CONFIGURATION-iphoneos/pubsdk.framework" build/output/device

cp -R build/output/device/pubsdk.framework build/output
rm build/output/pubsdk.framework/pubsdk

lipo -create -output build/output/pubsdk.framework/pubsdk build/output/sim/pubsdk.framework/pubsdk build/output/device/pubsdk.framework/pubsdk

cd build/output

zip -r "pubsdk.framework.$CRITEO_CONFIGURATION.zip" pubsdk.framework

cd ../..
