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
### ios version_bump
```
fastlane ios version_bump
```
Set marketing version
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
