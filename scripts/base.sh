#!/bin/bash -l

export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export CRITEO_ARCHS='arm64'
export CRITEO_SIM_ARCHS='x86_64 arm64'

# Note: writes to STDERR to prevent breaking xcpretty
function crto-printf() { printf "[🏔 crto] %s" "$@" 1>&2; }
function crto-echo() { printf "[🏔 crto] %s\n" "$@" 1>&2; }

export BUILD_PATH=build/output
function crto-clean() {
  crto-echo "Cleanup previous build..."
  rm -rf $BUILD_PATH
  mkdir -p $BUILD_PATH
}

# Stdout with xcpretty while putting full log in a file
export XCODEBUILD_LOG=$BUILD_PATH/xcodebuild.log
function crto-pretty() { tee -a $XCODEBUILD_LOG | xcpretty "$@"; }

function crto-build-simulator() {
  crto-echo "[simulator] build($*)"
  xcodebuild \
    -workspace CriteoPublisherSdk.xcworkspace \
    -scheme CriteoPublisherSdk \
    -configuration "$CRITEO_CONFIGURATION" \
    -IDEBuildOperationMaxNumberOfConcurrentCompileTasks="$(sysctl -n hw.ncpu)" \
    -derivedDataPath build/DerivedData \
    -sdk iphonesimulator \
    ARCHS="$CRITEO_SIM_ARCHS" \
    VALID_ARCHS="$CRITEO_SIM_ARCHS" \
    ONLY_ACTIVE_ARCH=NO \
    OTHER_CFLAGS="-fembed-bitcode" \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    BITCODE_GENERATION_MODE="bitcode" \
    ENABLE_BITCODE=NO \
    "$@"
}

function crto-build-device() {
  crto-echo "[device] build($*)"
  xcodebuild \
    -workspace CriteoPublisherSdk.xcworkspace \
    -scheme CriteoPublisherSdk \
    -configuration "$CRITEO_CONFIGURATION" \
    -IDEBuildOperationMaxNumberOfConcurrentCompileTasks="$(sysctl -n hw.ncpu)" \
    -derivedDataPath build/DerivedData \
    -sdk iphoneos \
    ARCHS="$CRITEO_ARCHS" \
    VALID_ARCHS="$CRITEO_ARCHS" \
    ONLY_ACTIVE_ARCH=NO \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    OTHER_CFLAGS="-fembed-bitcode" \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    BITCODE_GENERATION_MODE="bitcode" \
    ENABLE_BITCODE=NO \
    "$@"
}

function crto-build-xcframework() {
  CRITEO_CONFIGURATION=${1:-Debug}
  crto-echo "Building $CRITEO_CONFIGURATION..."

  mkdir -p "$BUILD_PATH"/simulator
  crto-build-simulator clean build | crto-pretty
  cp -R "build/DerivedData/Build/Products/$CRITEO_CONFIGURATION-iphonesimulator/CriteoPublisherSdk.framework" "$BUILD_PATH"/simulator

  mkdir -p "$BUILD_PATH"/device
  crto-build-device build | crto-pretty
  cp -R "build/DerivedData/Build/Products/$CRITEO_CONFIGURATION-iphoneos/CriteoPublisherSdk.framework" "$BUILD_PATH"/device

  crto-echo "Building xcframework..."
  XCFRAMEWORK_PATH="$BUILD_PATH"/CriteoPublisherSdk.xcframework
  rm -rf "$XCFRAMEWORK_PATH"
  xcodebuild -create-xcframework \
    -framework "$BUILD_PATH"/device/CriteoPublisherSdk.framework \
    -framework "$BUILD_PATH"/simulator/CriteoPublisherSdk.framework \
    -output "$XCFRAMEWORK_PATH"
}

function crto-archive() {
  cp LICENSE "$BUILD_PATH"
  pushd "$BUILD_PATH"
  crto-echo "Archiving..."
  zip -r "CriteoPublisherSdk.$CRITEO_CONFIGURATION.zip" \
    CriteoPublisherSdk.xcframework \
    LICENSE
  popd
}

function crto-remove-headers() {
  pushd "$BUILD_PATH"/CriteoPublisherSdk.framework/Headers
  crto-echo "Removing public headers..."
  for header in "$@"; do {
    crto-echo "Removing $header"
    sed -i '' "/$header/d" CriteoPublisherSdk.h
    rm $header
  }; done
  popd
}
