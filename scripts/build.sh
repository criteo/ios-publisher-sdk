#!/bin/bash -l

set +x

rm -rf build/output
mkdir -p build/output/sim

CONFIGURATION="Release"

set -o pipefail && xcodebuild \
    -workspace fuji.xcworkspace \
        -scheme pubsdk \
        -configuration $CONFIGURATION \
        -IDEBuildOperationMaxNumberOfConcurrentCompileTasks=`sysctl -n hw.ncpu` \
        -derivedDataPath build/DerivedData  \
        -sdk iphonesimulator \
        -destination 'platform=iOS Simulator,name=iPhone XS,OS=latest' \
        ARCHS='i386 x86_64' \
        VALID_ARCHS='i386 x86_64' \
        ONLY_ACTIVE_ARCH=NO \
        clean build | xcpretty --report junit --report html

        cp -R "build/DerivedData/Build/Products/$CONFIGURATION-iphonesimulator/pubsdk.framework" build/output/sim

        mkdir -p build/output/device

        xcodebuild \
    -workspace fuji.xcworkspace \
        -scheme pubsdk \
        -configuration $CONFIGURATION \
        -IDEBuildOperationMaxNumberOfConcurrentCompileTasks=`sysctl -n hw.ncpu` \
        -derivedDataPath build/DerivedData  \
        -sdk iphoneos \
        ARCHS='armv7 armv7s arm64 arm64e' \
        VALID_ARCHS='armv7 armv7s arm64 arm64e' \
        ONLY_ACTIVE_ARCH=NO \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        build | xcpretty --report junit --report html

        cp -R "build/DerivedData/Build/Products/$CONFIGURATION-iphoneos/pubsdk.framework" build/output/device

cp -R build/output/device/pubsdk.framework build/output
rm build/output/pubsdk.framework/pubsdk

lipo -create -output build/output/pubsdk.framework/pubsdk build/output/sim/pubsdk.framework/pubsdk build/output/device/pubsdk.framework/pubsdk

cd build/output

zip -r "pubsdk.framework.$CONFIGURATION.zip" pubsdk.framework

cd ../..


CONFIGURATION="Debug"

set -o pipefail && xcodebuild \
    -workspace fuji.xcworkspace \
        -scheme pubsdk \
        -configuration $CONFIGURATION \
        -IDEBuildOperationMaxNumberOfConcurrentCompileTasks=`sysctl -n hw.ncpu` \
        -derivedDataPath build/DerivedData  \
        -sdk iphonesimulator \
        -destination 'platform=iOS Simulator,name=iPhone XS,OS=latest' \
        ARCHS='i386 x86_64' \
        VALID_ARCHS='i386 x86_64' \
        ONLY_ACTIVE_ARCH=NO \
        clean build | xcpretty --report junit --report html

        cp -R "build/DerivedData/Build/Products/$CONFIGURATION-iphonesimulator/pubsdk.framework" build/output/sim

        mkdir -p build/output/device

        xcodebuild \
    -workspace fuji.xcworkspace \
        -scheme pubsdk \
        -configuration $CONFIGURATION \
        -IDEBuildOperationMaxNumberOfConcurrentCompileTasks=`sysctl -n hw.ncpu` \
        -derivedDataPath build/DerivedData  \
        -sdk iphoneos \
        ARCHS='armv7 armv7s arm64 arm64e' \
        VALID_ARCHS='armv7 armv7s arm64 arm64e' \
        ONLY_ACTIVE_ARCH=NO \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        build | xcpretty --report junit --report html

        cp -R "build/DerivedData/Build/Products/$CONFIGURATION-iphoneos/pubsdk.framework" build/output/device

cp -R build/output/device/pubsdk.framework build/output
rm build/output/pubsdk.framework/pubsdk

lipo -create -output build/output/pubsdk.framework/pubsdk build/output/sim/pubsdk.framework/pubsdk build/output/device/pubsdk.framework/pubsdk

cd build/output

zip -r "pubsdk.framework.$CONFIGURATION.zip" pubsdk.framework

cd ../..
