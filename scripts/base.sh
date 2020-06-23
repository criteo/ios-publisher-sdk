#!/bin/bash -l

export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export CRITEO_WATCH_ARCHS='armv7k arm64_32'
export CRITEO_DEVICE_ARCHS='armv7 armv7s arm64'
export CRITEO_ARCHS="$CRITEO_DEVICE_ARCHS $CRITEO_WATCH_ARCHS"
export CRITEO_SIM_ARCHS='i386 x86_64'

# Configuration for compiling the project for the simulator.
# We could set a fixed OS version instead of the "latest" to produce the same output from any env
export XCODEBUILD_DESTINATION_SIMULATOR_OS="latest"
export XCODEBUILD_DESTINATION_SIMULATOR_DEVICE="iPhone Xs"
export XCODEBUILD_DESTINATION_SIMULATOR_NAME="Fuji PreSubmit Tests Simulator"
export XCODEBUILD_DESTINATION_SIMULATOR="platform=iOS Simulator,name=${XCODEBUILD_DESTINATION_SIMULATOR_NAME},OS=${XCODEBUILD_DESTINATION_SIMULATOR_OS}"

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
