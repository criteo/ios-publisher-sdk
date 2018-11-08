#!/bin/bash -l

set -o pipefail && xcodebuild \
	-workspace fuji.xcworkspace \
        -scheme AdViewer \
        -IDEBuildOperationMaxNumberOfConcurrentCompileTasks=`sysctl -n hw.ncpu` \
        -derivedDataPath build/DerivedData  \
        -sdk iphonesimulator \
        -destination 'platform=iOS Simulator,name=iPhone 5s,OS=latest' \
        clean build test | xcpretty --report junit --report html
