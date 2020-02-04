#!/bin/bash -l

# Run this script to install your machine for the project.

set +x
set -Eeuo pipefail

# Mute flooding logs
# https://stackoverflow.com/questions/52455652/xcode-10-seems-to-break-com-apple-commcenter-coretelephony-xpc
xcrun simctl spawn booted log config --mode "level:off"  --subsystem com.apple.CoreTelephony
