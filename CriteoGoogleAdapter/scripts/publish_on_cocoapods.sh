#!/bin/bash -l

set +x
set -Eeuo pipefail

SCRIPT_DIRECTORY="$( cd "$(dirname "$0")" ; pwd -P )"
ROOT_DIRECTORY="${SCRIPT_DIRECTORY}/.."
POD_SPEC="${ROOT_DIRECTORY}/CriteoGoogleMediationAdapters.podspec"

echo "Hint:"
echo -e "\tThe 'pod trunk' command doesn't like the Criteo VPN."
echo -e "\tDisconnect from the VPN before running the script if you are connected."
echo ""

echo "Run 'pod update' to ensure that the last version of the CriteoPublisherSdk is cached."
echo "'pod spec lint' can failed if if is not the case."
pod update

echo "Verify the podspec file"
pod spec lint "${POD_SPEC}"
echo "Publish on Cocoapods"
pod trunk push "${POD_SPEC}"
