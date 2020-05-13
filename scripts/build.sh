#!/bin/bash -l
set +x
set -Eeuo pipefail

export LANG=en_US.UTF-8

rm -rf build/output
mkdir -p build/output/sim

pod install --repo-update
CRITEO_WATCH_ARCHS='armv7k arm64_32'
CRITEO_DEVICE_ARCHS='armv7 armv7s arm64'
CRITEO_ARCHS="$CRITEO_DEVICE_ARCHS $CRITEO_WATCH_ARCHS"
CRITEO_SIM_ARCHS='i386 x86_64'

CRITEO_CONFIGURATION="Release"
printf "Launching $CRITEO_CONFIGURATION build\nARCHS: $CRITEO_ARCHS\nSIM ARCHS: $CRITEO_SIM_ARCHS\n"

rm -rf fuji
rm -rf CriteoPublisher.framework
git clone ssh://qabot@review.crto.in:29418/pub-sdk/fuji

cd fuji

pod install

mkdir -p build/output/sim

xcodebuild \
    -workspace fuji.xcworkspace \
        -scheme CriteoPublisherSdk \
        -configuration $CRITEO_CONFIGURATION \
        -IDEBuildOperationMaxNumberOfConcurrentCompileTasks=`sysctl -n hw.ncpu` \
        -derivedDataPath build/DerivedData  \
        -sdk iphonesimulator \
        -destination 'platform=iOS Simulator,name=iPhone 11,OS=latest' \
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
        OTHER_CFLAGS="-fembed-bitcode" \
        build | xcpretty

        cp -R "build/DerivedData/Build/Products/$CRITEO_CONFIGURATION-iphoneos/CriteoPublisherSdk.framework" build/output/device

cp -R build/output/device/CriteoPublisherSdk.framework build/output
rm build/output/CriteoPublisherSdk.framework/CriteoPublisherSdk

lipo -create -output build/output/CriteoPublisherSdk.framework/CriteoPublisherSdk build/output/sim/CriteoPublisherSdk.framework/CriteoPublisherSdk build/output/device/CriteoPublisherSdk.framework/CriteoPublisherSdk
echo "Fat Binary Contents for $CRITEO_CONFIGURATION Build:"
echo "----------------------------------------------------"
objdump -macho -universal-headers -arch all build/output/CriteoPublisherSdk.framework/CriteoPublisherSdk
echo "----------------------------------------------------"

cp -R build/output/CriteoPublisherSdk.framework ../AdViewer/

cd ..

set -o pipefail && xcodebuild \
	-workspace fuji-test-app.xcworkspace \
        -scheme AdViewer \
        -configuration debug \
        -IDEBuildOperationMaxNumberOfConcurrentCompileTasks=`sysctl -n hw.ncpu` \
        -derivedDataPath build/DerivedData  \
        -sdk iphonesimulator \
        -destination 'platform=iOS Simulator,name=iPhone 8,OS=latest' \
        clean build test | xcpretty --report junit --report html
