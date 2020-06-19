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

function fuji-build-simulator() {
  fuji-echo "[simulator] build($*)"
  xcodebuild \
    -workspace fuji.xcworkspace \
    -scheme CriteoPublisherSdk \
    -configuration "$CRITEO_CONFIGURATION" \
    -IDEBuildOperationMaxNumberOfConcurrentCompileTasks="$(sysctl -n hw.ncpu)" \
    -derivedDataPath build/DerivedData \
    -sdk iphonesimulator \
    -destination "${XCODEBUILD_DESTINATION_SIMULATOR}" \
    ARCHS="$CRITEO_SIM_ARCHS" \
    VALID_ARCHS="$CRITEO_SIM_ARCHS" \
    ONLY_ACTIVE_ARCH=NO \
    "$@"
}

function fuji-build-device() {
  fuji-echo "[device] build($*)"
  xcodebuild \
    -workspace fuji.xcworkspace \
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

CRITEO_CONFIGURATION="Release"
fuji-fat-build
fuji-archive

CRITEO_CONFIGURATION="Debug"
fuji-fat-build
fuji-archive

fuji-echo "Archive completed."
