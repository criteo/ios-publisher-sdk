fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
## iOS
### ios test
```
fastlane ios test
```
Install cert to simulator - for local testing using https

Run tests: Run Unit & Functional tests with retries
### ios format_check
```
fastlane ios format_check
```
Check code format
### ios format
```
fastlane ios format
```
Format code
### ios lint_swift
```
fastlane ios lint_swift
```
Lint swift code
### ios set_versions
```
fastlane ios set_versions
```
Sets marketing and bundle versions to a Xcode project
### ios version_bump
```
fastlane ios version_bump
```
Sets cocoapods, marketing and bundle versions from a semver `version` and an optional `build` number
### ios archive
```
fastlane ios archive
```
Generates Debug & Release frameworks zip archives
### ios github_release
```
fastlane ios github_release
```

### ios release_github
```
fastlane ios release_github
```
Archive then release version to GitHub
### ios release_cocoapods
```
fastlane ios release_cocoapods
```
Release version to CocoaPods

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
