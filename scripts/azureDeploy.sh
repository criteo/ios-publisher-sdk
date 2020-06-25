#!/bin/bash -l

set +x
set -Eeuo pipefail

SCRIPT_DIRECTORY="$(
  cd "$(dirname "$0")"
  pwd -P
)"

# TODO EE-1047 Get those credentials from a vault
if [[ -f "$SCRIPT_DIRECTORY/env.secret.sh" ]]; then
  source "$SCRIPT_DIRECTORY/env.secret.sh"
fi

release=$1
export container_name=publishersdk
export blob_name=ios/CriteoPublisherSdk_iOS_v${release}.Release.zip
export file_to_upload=./CriteoPublisherSdk_iOS_v${release}.Release.zip

echo "Uploading the file...${blob_name}"
az storage blob upload --container-name $container_name --file $file_to_upload --name $blob_name

echo "Listing the blobs..."
az storage blob list --container-name $container_name --output table


echo "Done"
