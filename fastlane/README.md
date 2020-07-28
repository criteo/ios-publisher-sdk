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
### ios last_changelog
```
fastlane ios last_changelog
```
Extract last version changelog

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
