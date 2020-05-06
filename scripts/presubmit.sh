#!/bin/bash -l

SCRIPT_DIRECTORY="$( cd "$(dirname "$0")" ; pwd -P )"
BUILD_SCRIPT_PATH="${SCRIPT_DIRECTORY}/build.sh"
VERIFY_SCRIPT_PATH="${SCRIPT_DIRECTORY}/verify-app-integration.sh"

$BUILD_SCRIPT_PATH "PresubmitTests"
$VERIFY_SCRIPT_PATH
