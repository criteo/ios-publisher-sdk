#!/bin/bash -l

set +x
set -Eeuo pipefail

SCRIPT_DIRECTORY="$(
  cd "$(dirname "$0")"
  pwd -P
)"
"${SCRIPT_DIRECTORY}"/setup.sh
"${SCRIPT_DIRECTORY}"/test.sh "PostsubmitTests"
"${SCRIPT_DIRECTORY}"/archive.sh
"${SCRIPT_DIRECTORY}"/test-app-integration.sh
