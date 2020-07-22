#!/bin/bash -l

set +x
set -Eeuo pipefail

rm -rf build/output
mkdir -p build/output/sim

pod install --repo-update

CRITEO_CONFIGURATION="Release"

rm -rf fuji
rm -rf CriteoPublisher.framework
git clone https://review.crto.in/pub-sdk/fuji

pushd fuji
source ./scripts/base.sh
./scripts/setup.sh
crto-fat-build $CRITEO_CONFIGURATION
cp -R build/output/CriteoPublisherSdk.framework ../
popd

    xcodebuild \
    -workspace CriteoMoPubAdapter.xcworkspace \
        -scheme CriteoMoPubAdapter \
        -configuration $CRITEO_CONFIGURATION \
        -IDEBuildOperationMaxNumberOfConcurrentCompileTasks=`sysctl -n hw.ncpu` \
        -derivedDataPath build/DerivedData  \
        -sdk iphonesimulator \
        -destination 'platform=iOS Simulator,name=iPhone 11,OS=latest' \
        ARCHS="$CRITEO_SIM_ARCHS" \
        VALID_ARCHS="$CRITEO_SIM_ARCHS" \
        ONLY_ACTIVE_ARCH=NO -verbose\
        clean build test | xcpretty

        cp -R "build/DerivedData/Build/Products/$CRITEO_CONFIGURATION-iphonesimulator/CriteoMoPubAdapter.framework" build/output/sim

        mkdir -p build/output/device

    xcodebuild \
    -workspace CriteoMoPubAdapter.xcworkspace \
        -scheme CriteoMoPubAdapter \
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

        cp -R "build/DerivedData/Build/Products/$CRITEO_CONFIGURATION-iphoneos/CriteoMoPubAdapter.framework" build/output/device

cp -R build/output/device/CriteoMoPubAdapter.framework build/output
rm build/output/CriteoMoPubAdapter.framework/CriteoMoPubAdapter

lipo -create -output build/output/CriteoMoPubAdapter.framework/CriteoMoPubAdapter build/output/sim/CriteoMoPubAdapter.framework/CriteoMoPubAdapter build/output/device/CriteoMoPubAdapter.framework/CriteoMoPubAdapter
echo "Fat Binary Contents for $CRITEO_CONFIGURATION Build:"
echo "----------------------------------------------------"
objdump -macho -universal-headers -arch all build/output/CriteoMoPubAdapter.framework/CriteoMoPubAdapter
echo "----------------------------------------------------"

cd build/output

zip -r "CriteoMoPubAdapter.framework.$CRITEO_CONFIGURATION.zip" CriteoMoPubAdapter.framework

cd ../..


CRITEO_CONFIGURATION="Debug"
printf "Launching $CRITEO_CONFIGURATION build\nARCHS: $CRITEO_ARCHS\nSIM ARCHS: $CRITEO_SIM_ARCHS\n"

    xcodebuild \
    -workspace CriteoMoPubAdapter.xcworkspace \
        -scheme CriteoMoPubAdapter \
        -configuration $CRITEO_CONFIGURATION \
        -IDEBuildOperationMaxNumberOfConcurrentCompileTasks=`sysctl -n hw.ncpu` \
        -derivedDataPath build/DerivedData  \
        -sdk iphonesimulator \
        -destination 'platform=iOS Simulator,name=iPhone 11,OS=latest' \
        ARCHS="$CRITEO_SIM_ARCHS" \
        VALID_ARCHS="$CRITEO_SIM_ARCHS" \
        ONLY_ACTIVE_ARCH=NO \
        clean build | xcpretty --report junit --report html

        cp -R "build/DerivedData/Build/Products/$CRITEO_CONFIGURATION-iphonesimulator/CriteoMoPubAdapter.framework" build/output/sim

        mkdir -p build/output/device

    xcodebuild \
    -workspace CriteoMoPubAdapter.xcworkspace \
        -scheme CriteoMoPubAdapter \
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

        cp -R "build/DerivedData/Build/Products/$CRITEO_CONFIGURATION-iphoneos/CriteoMoPubAdapter.framework" build/output/device

cp -R build/output/device/CriteoMoPubAdapter.framework build/output
rm build/output/CriteoMoPubAdapter.framework/CriteoMoPubAdapter

lipo -create -output build/output/CriteoMoPubAdapter.framework/CriteoMoPubAdapter build/output/sim/CriteoMoPubAdapter.framework/CriteoMoPubAdapter build/output/device/CriteoMoPubAdapter.framework/CriteoMoPubAdapter
echo "Fat Binary Contents for $CRITEO_CONFIGURATION Build:"
echo "----------------------------------------------------"
objdump -macho -universal-headers -arch all build/output/CriteoMoPubAdapter.framework/CriteoMoPubAdapter
echo "----------------------------------------------------"

cd build/output

zip -r "CriteoMoPubAdapter.framework.$CRITEO_CONFIGURATION.zip" CriteoMoPubAdapter.framework

cd ../..
