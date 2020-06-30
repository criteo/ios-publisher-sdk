#!/bin/bash -l

export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export CRITEO_WATCH_ARCHS='armv7k arm64_32'
export CRITEO_DEVICE_ARCHS='armv7 armv7s arm64'
export CRITEO_ARCHS="$CRITEO_DEVICE_ARCHS $CRITEO_WATCH_ARCHS"
export CRITEO_SIM_ARCHS='i386 x86_64'

# Note: writes to STDERR to prevent breaking xcpretty
function fuji-printf() { printf "[🏔 fuji] %s" "$@" 1>&2; }
function fuji-echo() { printf "[🏔 fuji] %s\n" "$@" 1>&2; }

export BUILD_PATH=build/output
function fuji-clean() {
  fuji-echo "Cleanup previous build..."
  rm -rf $BUILD_PATH
  mkdir -p $BUILD_PATH
}

# Stdout with xcpretty while putting full log in a file
export XCODEBUILD_LOG=$BUILD_PATH/xcodebuild.log
function fuji-pretty() { tee -a $XCODEBUILD_LOG | xcpretty "$@"; }

function fuji-build-simulator() {
  fuji-echo "[simulator] build($*)"
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
    "$@"
}

function fuji-build-device() {
  fuji-echo "[device] build($*)"
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
    "$@"
}

function fuji-fat-build() {
  CRITEO_CONFIGURATION=${1:-Debug}
  fuji-echo "Building $CRITEO_CONFIGURATION..."

  mkdir -p "$BUILD_PATH"/simulator
  fuji-build-simulator clean build | fuji-pretty
  cp -R "build/DerivedData/Build/Products/$CRITEO_CONFIGURATION-iphonesimulator/CriteoPublisherSdk.framework" "$BUILD_PATH"/simulator

  mkdir -p "$BUILD_PATH"/device
  fuji-build-device build | fuji-pretty
  cp -R "build/DerivedData/Build/Products/$CRITEO_CONFIGURATION-iphoneos/CriteoPublisherSdk.framework" "$BUILD_PATH"/device
  cp -R "$BUILD_PATH"/device/CriteoPublisherSdk.framework "$BUILD_PATH"
  rm "$BUILD_PATH"/CriteoPublisherSdk.framework/CriteoPublisherSdk

  lipo -create -output "$BUILD_PATH"/CriteoPublisherSdk.framework/CriteoPublisherSdk "$BUILD_PATH"/simulator/CriteoPublisherSdk.framework/CriteoPublisherSdk "$BUILD_PATH"/device/CriteoPublisherSdk.framework/CriteoPublisherSdk
  fuji-echo "Fat Binary Contents for $CRITEO_CONFIGURATION Build:"
  objdump -macho -universal-headers -arch all "$BUILD_PATH"/CriteoPublisherSdk.framework/CriteoPublisherSdk
}

function fuji-archive() {
  pushd "$BUILD_PATH"
  fuji-echo "Archiving..."
  zip -r "CriteoPublisherSdk.framework.$CRITEO_CONFIGURATION.zip" CriteoPublisherSdk.framework
  popd
}

function fuji-remove-headers() {
  pushd "$BUILD_PATH"/CriteoPublisherSdk.framework/Headers
  fuji-echo "Removing public headers..."
  for header in "$@"; do {
    fuji-echo "Removing $header"
    sed -i '' "/$header/d" CriteoPublisherSdk.h
    rm $header
  }; done
  popd
}