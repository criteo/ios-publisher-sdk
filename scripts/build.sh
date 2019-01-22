#!/bin/bash -l
set -o pipefail && xcrun simctl list && xcodebuild \
	-workspace fuji.xcworkspace \
        -scheme pubsdk \
        -IDEBuildOperationMaxNumberOfConcurrentCompileTasks=`sysctl -n hw.ncpu` \
        -derivedDataPath build/DerivedData  \
        -sdk iphonesimulator \
        -destination 'platform=iOS Simulator,name=iPhone XS,OS=12.0' \
        clean build test | xcpretty --report junit --report html
