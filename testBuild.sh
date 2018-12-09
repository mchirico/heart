#!/bin/bash
cd swift/heart
xcodebuild clean build -workspace heart.xcworkspace -scheme heart CODE_SIGNING_REQUIRED=NO -destination 'platform=iOS Simulator,name=iPhone X,OS=11.4' -quiet
xcodebuild test -workspace heart.xcworkspace -scheme heart -destination 'platform=iOS Simulator,name=iPhone X,OS=11.4' -enableCodeCoverage  YES -quiet
