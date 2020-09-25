#!/bin/bash -l


set +x
set -Eeuo pipefail

SCRIPT_DIRECTORY="$(
  cd "$(dirname "$0")"
  pwd -P
)"
# shellcheck source=scripts/base.sh
source "$SCRIPT_DIRECTORY"/base.sh

crto-echo "[Bundle] Updating Gems..."
bundle update
crto-echo "[CocoaPods] Updating Pods..."
bundle exec pod update
crto-echo "[Includes] Updating included libs..."
"$SCRIPT_DIRECTORY"/import-cassette.sh

crto-echo "Update complete."
