#!/bin/bash -l

set +x
set -Eeuo pipefail

SCRIPT_DIRECTORY="$(
  cd "$(dirname "$0")"
  pwd -P
)"
# shellcheck source=scripts/base.sh
source "$SCRIPT_DIRECTORY"/base.sh

crto-echo "Checking tool versions"
crto-printf "xcpretty "
xcpretty -version
crto-printf
xcodebuild -version
crto-printf
ruby --version
crto-printf
bundle --version

crto-echo "Bundle install..."
bundle install --path vendor

crto-echo "CocoaPods install..."
bundle exec fastlane run cocoapods