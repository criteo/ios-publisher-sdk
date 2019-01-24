#!/bin/bash -l
set -o pipefail && xcrun simctl list && xcodebuild \
	-workspace fuji.xcworkspace \
        -scheme pubsdk \
        -IDEBuildOperationMaxNumberOfConcurrentCompileTasks=`sysctl -n hw.ncpu` \
        -derivedDataPath build/DerivedData  \
        -sdk iphonesimulator \
        -destination 'platform=iOS Simulator,name=iPhone XS,OS=latest' \
        clean build test | xcpretty --report junit --report html
