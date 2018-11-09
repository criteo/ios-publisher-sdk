#!/bin/bash -l

# Building for generic device

set -o pipefail && xcodebuild \
	-workspace fuji-test-app.xcworkspace \
        -scheme AdViewer \
        -configuration release \
        -IDEBuildOperationMaxNumberOfConcurrentCompileTasks=`sysctl -n hw.ncpu` \
        -derivedDataPath build/DerivedData  \
        -sdk iphonesimulator \
        -destination 'generic/platform=iOS' \
        clean build-for-testing  | xcpretty 


# We can start multiple testing sessions for different devices

# List of devices you can get with 
# $ instruments -s devices

set -o pipefail && xcodebuild \
	-workspace fuji-test-app.xcworkspace \
        -scheme AdViewer \
        -configuration release \
        -IDEBuildOperationMaxNumberOfConcurrentCompileTasks=`sysctl -n hw.ncpu` \
        -derivedDataPath build/DerivedData  \
        -sdk iphonesimulator \
        -destination 'platform=iOS Simulator,name=iPhone 5s,OS=latest' \
        -destination 'platform=iOS Simulator,name=iPhone XR,OS=latest' \
        test-without-building  | xcpretty --report junit --report html

