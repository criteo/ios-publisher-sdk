#!/bin/bash -l

set +x
set -Eeuo pipefail

SCRIPT_DIRECTORY="$(
  cd "$(dirname "$0")"
  pwd -P
)"
# shellcheck source=scripts/base.sh
source "$SCRIPT_DIRECTORY"/base.sh

fuji-echo "Checking tool versions"
fuji-printf "xcpretty "
xcpretty -version
fuji-printf
xcodebuild -version
fuji-printf
ruby --version
fuji-printf
bundle --version

fuji-echo "Bundle install..."
bundle install --path vendor

fuji-echo "CocoaPods install..."
bundle exec fastlane run cocoapods