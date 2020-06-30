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

fuji-fat-build Release
fuji-archive

fuji-fat-build Debug
fuji-archive

fuji-echo "Archive completed."
