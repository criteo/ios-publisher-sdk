#!/bin/bash -l
#
# Clone the testing app of fuji, compile it and test it.
# /!\ Don't forget to compile the SDK before.
#
set +x
set -Eeuo pipefail

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"
ROOT_DIR_PATH="${SCRIPT_PATH}/.."
BUILD_DIR_PATH="${ROOT_DIR_PATH}/build"
SDK_PATH="${BUILD_DIR_PATH}/output/CriteoPublisherSdk.framework"
APP_DIR_PATH="${BUILD_DIR_PATH}/testing-app"
SDK_PATH_IN_APP="${APP_DIR_PATH}/fuji-test-app/AdViewer/CriteoPublisherSdk.framework"

# Check if the SDK has already been compiled
if [[ ! -d "${SDK_PATH}" ]]; then
    >&2 echo "[ERROR] The SDK package is missing: ${SDK_PATH}"
    >&2 echo "[ERROR] Build the SDK first."
    exit 1
fi

# Clean up the directory of the testing-app
rm -rf $APP_DIR_PATH
mkdir -p $APP_DIR_PATH

# Retrieve and compile the testing app
cd $APP_DIR_PATH
git clone --branch v3.6.1 https://review.crto.in/pub-sdk/fuji-test-app
cd fuji-test-app
cp -R $SDK_PATH $SDK_PATH_IN_APP
./scripts/compile-test.sh
