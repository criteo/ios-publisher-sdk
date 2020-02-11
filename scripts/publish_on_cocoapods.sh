#!/bin/bash -l

set +x
set -Eeuo pipefail

SCRIPT_DIRECTORY="$( cd "$(dirname "$0")" ; pwd -P )"
ROOT_DIRECTORY="${SCRIPT_DIRECTORY}/.."
POD_SPEC="${ROOT_DIRECTORY}/CriteoMoPubMediationAdapters.podspec"

echo "Hint:"
echo -e "\tThe 'pod trunk' command doesn't like the Criteo VPN."
echo -e "\tDisconnect from the VPN before running the script if you are connected."
echo ""

echo "Verify the podspec file"
pod spec lint "${POD_SPEC}"
echo "Publish on Cocoapods"
pod trunk push "${POD_SPEC}"
