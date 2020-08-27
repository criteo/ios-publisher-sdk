#!/bin/bash -l
set +x
set -Eeuo pipefail

export LANG=en_US.UTF-8

rm -rf build/output
mkdir -p build/output/sim

# Note: writes to STDERR to prevent breaking xcpretty
function crto-printf() { printf "[🏔 crto] $*" 1>&2; }
function crto-echo() { printf "[🏔 crto] $*\n" 1>&2; }

function crto-pod-repo-update() {
  crto-echo "Cocoapods repo update..."
  pod repo update --silent
}
function crto-pod-install() {
  crto-echo "Cocoapods install..."
  pod install --deployment --clean-install --no-repo-update
}
crto-pod-repo-update
crto-pod-install

rm -rf fuji
rm -rf CriteoPublisher.framework
git clone https://review.crto.in/pub-sdk/fuji

pushd fuji
source ./scripts/base.sh
./scripts/setup.sh
crto-fat-build Release
cp -R build/output/CriteoPublisherSdk.framework ../AdViewer/
popd

set -o pipefail && xcodebuild \
        -workspace fuji-test-app.xcworkspace \
        -scheme AdViewer \
        -configuration debug \
        -IDEBuildOperationMaxNumberOfConcurrentCompileTasks=`sysctl -n hw.ncpu` \
        -derivedDataPath build/DerivedData  \
        -sdk iphonesimulator \
        -destination 'platform=iOS Simulator,name=iPhone 8,OS=latest' \
        clean build test | xcpretty --report junit --report html
