#!/bin/bash -l

set +x
set -Eeuo pipefail

SCRIPT_DIRECTORY="$(
  cd "$(dirname "$0")"
  pwd -P
)"
# shellcheck source=scripts/base.sh
source "$SCRIPT_DIRECTORY"/base.sh
"${SCRIPT_DIRECTORY}"/setup.sh
#"${SCRIPT_DIRECTORY}"/test.sh "PresubmitTests"

bundle exec fastlane tests
