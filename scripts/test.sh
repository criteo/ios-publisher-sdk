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

fuji-echo "CocoaPods repo update..."
pod repo update --silent
fuji-echo "CocoaPods install..."
pod install --deployment --clean-install --no-repo-update

if [ $# -eq 0 ]; then
  XCODEBUILD_SCHEME_FOR_TESTING="CriteoPublisherSdk"
else
  XCODEBUILD_SCHEME_FOR_TESTING="$1"
fi
fuji-echo "Selected SCHEME for testing: ${XCODEBUILD_SCHEME_FOR_TESTING}"

# Delete the left over simulators from previous xcode version
xcrun simctl delete unavailable

# Get the identifier of the selected simulator runtime
#SIMULATOR_RUNTIME_AVAILABLE=$(xcrun simctl list runtimes | grep iOS | grep "${XCODEBUILD_DESTINATION_SIMULATOR_OS}" | awk '{print $NF}' || true)
#if [ -z "$SIMULATOR_RUNTIME_AVAILABLE" ]; then
#    fuji-echo "[ERROR] The selected simulator runtime ${XCODEBUILD_DESTINATION_SIMULATOR_OS}"
#    fuji-echo "Available simulator runtime:"
#    xcrun simctl list runtimes
#    exit 1
#else
#    fuji-echo "Runtime identifier for ${XCODEBUILD_DESTINATION_SIMULATOR_OS}: ${SIMULATOR_RUNTIME_AVAILABLE}"
#fi

# Get the identifier of the selected simulator device
SIMULATOR_DEVICE_TYPE_AVAILABLE=$(xcrun simctl list devicetypes | grep --ignore-case "${XCODEBUILD_DESTINATION_SIMULATOR_DEVICE}" | head -n 1 | cut -f2 -d'(' | cut -f1 -d')' || true)
if [ -z "$SIMULATOR_DEVICE_TYPE_AVAILABLE" ]; then
  fuji-echo "[ERROR] The selected simulator devicetype ${XCODEBUILD_DESTINATION_SIMULATOR_DEVICE}"
  fuji-echo 'Available devicetypes:'
  xcrun simctl list devicetypes
  exit 1
else
  fuji-echo "Runtime identifier for ${XCODEBUILD_DESTINATION_SIMULATOR_DEVICE}: ${SIMULATOR_DEVICE_TYPE_AVAILABLE}"
fi

# Delete and re-create the simulator device to ensure isolation
fuji-echo "Deleting the previous test run simulator..."
xcrun simctl delete \
  "${XCODEBUILD_DESTINATION_SIMULATOR_NAME}" ||
  true
fuji-echo "Creating the simulator ${XCODEBUILD_DESTINATION_SIMULATOR_NAME}..."
xcrun simctl create \
  "${XCODEBUILD_DESTINATION_SIMULATOR_NAME}" \
  "$SIMULATOR_DEVICE_TYPE_AVAILABLE" #\
#    $SIMULATOR_RUNTIME_AVAILABLE

function fuji-test() {
  fuji-echo "Test $2($1)"
  xcodebuild \
    -workspace fuji.xcworkspace \
    -scheme "${XCODEBUILD_SCHEME_FOR_TESTING}" \
    -IDEBuildOperationMaxNumberOfConcurrentCompileTasks="$(sysctl -n hw.ncpu)" \
    -derivedDataPath build/DerivedData \
    -sdk iphonesimulator \
    -destination "${XCODEBUILD_DESTINATION_SIMULATOR}" \
    $1 \
    ARCHS="$CRITEO_SIM_ARCHS" \
    VALID_ARCHS="$CRITEO_SIM_ARCHS" \
    ONLY_ACTIVE_ARCH=NO \
    $2
}

fuji-test "" build-for-testing | fuji-pretty
fuji-test "-only-testing pubsdkITests" test-without-building |
  fuji-pretty --report junit --report html
fuji-test "-only-testing pubsdkTests" test-without-building |
  fuji-pretty --report junit --report html

fuji-echo "Tests completed."
