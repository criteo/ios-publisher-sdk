fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios test

```sh
[bundle exec] fastlane ios test
```

Run tests: Run Unit & Functional tests with retries

### ios test_0

```sh
[bundle exec] fastlane ios test_0
```

Run tests: Run Unit & Functional tests with retries

### ios test_1

```sh
[bundle exec] fastlane ios test_1
```

Run tests: Run Unit & Functional tests with retries

### ios test_2

```sh
[bundle exec] fastlane ios test_2
```

Run tests: Run Unit & Functional tests with retries

### ios format_check

```sh
[bundle exec] fastlane ios format_check
```

Check code format

### ios format

```sh
[bundle exec] fastlane ios format
```

Format code

### ios lint_swift

```sh
[bundle exec] fastlane ios lint_swift
```

Lint swift code

### ios set_versions

```sh
[bundle exec] fastlane ios set_versions
```

Sets marketing and bundle versions to a Xcode project

### ios version_bump

```sh
[bundle exec] fastlane ios version_bump
```

Sets cocoapods, marketing and bundle versions from a semver `version` and an optional `build` number

### ios archive

```sh
[bundle exec] fastlane ios archive
```

Generates Debug & Release frameworks zip archives

### ios github_release

```sh
[bundle exec] fastlane ios github_release
```



### ios release_github

```sh
[bundle exec] fastlane ios release_github
```

Archive then release version to GitHub

### ios release_cocoapods

```sh
[bundle exec] fastlane ios release_cocoapods
```

Release version to CocoaPods

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
