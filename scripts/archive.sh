#!/bin/bash -l

set -x
set -Eeuo pipefail

SCRIPT_DIRECTORY="$(
  cd "$(dirname "$0")"
  pwd -P
)"
# shellcheck source=scripts/base.sh
source "$SCRIPT_DIRECTORY"/base.sh

crto-clean

crto-fat-build Release
crto-archive

crto-fat-build Debug
crto-archive

crto-echo "Archive completed."
