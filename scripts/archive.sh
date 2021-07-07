#!/bin/bash -l

set +x
set -Eeuo pipefail

SCRIPT_DIRECTORY="$(
  cd "$(dirname "$0")"
  pwd -P
)"
# shellcheck source=scripts/base.sh
source "$SCRIPT_DIRECTORY"/base.sh

crto-clean

crto-build-xcframework Release
crto-archive

crto-build-xcframework Debug
crto-archive

crto-echo "Archive completed."
