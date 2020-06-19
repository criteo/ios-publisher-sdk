#!/bin/bash -l

set +x
set -Eeuo pipefail

SCRIPT_DIRECTORY="$(
  cd "$(dirname "$0")"
  pwd -P
)"
"${SCRIPT_DIRECTORY}"/test.sh "PresubmitTests"
