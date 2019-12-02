#!/bin/bash -l
#
# Compile and test the testing app.
# /!\ Don't forget to add the fuji SDK within the good directory.
#
set +x
set -Eeuo pipefail

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"
ROOT_PATH="${SCRIPT_PATH}/.."
FUJI_PATH="${ROOT_PATH}/AdViewer/CriteoPublisherSdk.framework"

if [[ ! -d "${FUJI_PATH}" ]]; then
    >&2 echo "[ERROR] The SDK file is missing: ${FUJI_PATH}"
    exit 1
fi

cd $ROOT_PATH

pod install

xcodebuild \
    -workspace fuji-test-app.xcworkspace \
    -scheme AdViewer \
    -configuration debug \
    -derivedDataPath build/DerivedData  \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 5s,OS=latest' \
    clean build test | xcpretty --report junit --report html
