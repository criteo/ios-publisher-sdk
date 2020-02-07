#!/bin/bash -l

# Prepare the publication on Github
# https://github.com/criteo/ios-publisher-sdk-mopub-adapters.git

set +x
set -Eeuo pipefail

if [ $# -ne 2 ]; then
    echo "Missing parameters:"
    echo -e "\tArg #1: the version of the tag"
    echo -e "\tArg #2: the commit message of the publication"
    exit 1
fi

TAGGED_VERSION="$1"
COMMIT_MESSAGE="$2"
SCRIPT_DIRECTORY="$( cd "$(dirname "$0")" ; pwd -P )"
ROOT_DIRECTORY="${SCRIPT_DIRECTORY}/.."
RELEASE_DIRECTORY="${ROOT_DIRECTORY}/Release"
PROJECT_FILE_DIRECTORY="${ROOT_DIRECTORY}/CriteoMoPubAdapter"
RELEASE_FILE_DIRECTORY="${RELEASE_DIRECTORY}/ios-publisher-sdk-mopub-adapters"
PROJECT_CHANGELOG_PATH="${ROOT_DIRECTORY}/CHANGELOG.md"
RELEASE_CHANGELOG_PATH="${RELEASE_FILE_DIRECTORY}/CHANGELOG.md"

echo "Prepare the release directory"
rm -rf "$RELEASE_DIRECTORY"
mkdir -p "$RELEASE_DIRECTORY"
cd "$RELEASE_DIRECTORY"

echo "Download the github repository"
git clone https://github.com/criteo/ios-publisher-sdk-mopub-adapters.git "${RELEASE_FILE_DIRECTORY}"

echo "Moving the implementation files in the Github clone:"
PROJECT_FILE_PATHS=$(find "${PROJECT_FILE_DIRECTORY}" -name '*.[h|m]')
while IFS= read -r FILE_PATH; do
    cp "$FILE_PATH" "${RELEASE_FILE_DIRECTORY}"

    FILE_NAME=$(basename "${FILE_PATH}")
    echo -e "\t->\t${FILE_NAME}"
done <<< "${PROJECT_FILE_PATHS}"

if [ -f "${RELEASE_CHANGELOG_PATH}" ]; then
    echo "Verify if changelog has changed:"
    if cmp -s "${PROJECT_CHANGELOG_PATH}" "${RELEASE_CHANGELOG_PATH}"; then
        echo -e "\tKO"
        exit 1
    else
        echo -e "\tOK"
    fi
fi

echo "Moving the changelog in the Github clone"
cp "${PROJECT_CHANGELOG_PATH}" "${RELEASE_CHANGELOG_PATH}"

echo "Creating commit and tag"
cd "${RELEASE_FILE_DIRECTORY}"
git add .
git commit -m "${COMMIT_MESSAGE}"
git tag "${TAGGED_VERSION}"
git log -1 --stat

echo "If the preparation is correct, use the following commands:"
echo ""
echo -e "\tgit push origin master && git push origin ${TAGGED_VERSION}"
echo ""