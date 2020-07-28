# Development

## Setup
We are using [Bundler](https://bundler.io) for ruby gems installation, for installing
[CocoaPods](https://cocoapods.org) and [fastlane](https://fastlane.tools).
Make sure to install bundler and then run `./scripts/setup.sh` that will install gems and pods.
Then use bundler to run fastlane actions such as `bundle exec fastlane test`.

## General practices
Follow the Robert Martin suggestion about [Clean Code](https://gist.github.com/wojteklu/73c6914cc446146b8b533c0988cf8d29).

## Coding Style
To ensure code style consistency, it must respect the following:
1. Formatted with [Clang Format](https://clang.llvm.org/docs/ClangFormat.html). This is checked by
  CI and can be applied easily with `bundle exec fastlane format`.
2. Follow [Ray Wenderlich's coding style](https://github.com/raywenderlich/objective-c-style-guide).

## Tests

As much as possible, respect the ["Arrange, Act, Assert" convention](http://wiki.c2.com/?ArrangeActAssert) in the tests.

The tests in this project are organised according to the following conventions:
- Unit tests are located within the [UnitTests](CriteoPublisherSdk/Tests/UnitTests) directory.
- Integration tests are written in the [IntegrationTests](CriteoPublisherSdk/Tests/IntegrationTests) directory.
- The subset of integration tests which represent one of the functional tests defined [here](https://go.crto.in/publisher-sdk-functional-tests)
 are post-fixed with `FunctionTests`. The rest are post-fixed with `IntegrationTests`.

## Release

1. Bump version: `bundle exec fastlane version_bump version:4.0.0`
2. Check changes and merge
3. Ensure `CHANGELOG.md` is up to date
4. Tag the version on GitHub then check the CI result on (releases)[http://github.com/criteo/ios-publisher-sdk/releases]
6. Review GitHub release draft, if wanted uncheck the pre-release flag, publish
7. Profit 🚀🥳
