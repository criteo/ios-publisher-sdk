#!/bin/bash -l

# Run this script to install your machine for the project.

set +x
set -Eeuo pipefail

# Mute flooding logs
# https://stackoverflow.com/questions/52455652/xcode-10-seems-to-break-com-apple-commcenter-coretelephony-xpc
xcrun simctl spawn booted log config --mode "level:off"  --subsystem com.apple.CoreTelephony

# Enable parallel builds on Xcode
num_cpu=$(sysctl -n hw.ncpu)
defaults write com.apple.dt.xcodebuild PBXNumberOfParallelBuildSubtasks "$num_cpu"
defaults write com.apple.dt.xcodebuild IDEBuildOperationMaxNumberOfConcurrentCompileTasks "$num_cpu"
defaults write com.apple.dt.Xcode PBXNumberOfParallelBuildSubtasks "$num_cpu"
defaults write com.apple.dt.Xcode IDEBuildOperationMaxNumberOfConcurrentCompileTasks "$num_cpu"

# Code format
brew install clang-format swift-format swiftlint
cp tools/code-format-git-hook.sh .git/hooks/pre-commit
