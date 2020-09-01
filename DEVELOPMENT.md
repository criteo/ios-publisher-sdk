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
1. Code Formatted:
    - Obj-C: [Clang Format](https://clang.llvm.org/docs/ClangFormat.html). _(Checked by CI)_
    - Swift: [swift-format](https://github.com/apple/swift-format). _(Not checked by CI)_
    - You can format whole repository with `bundle exec fastlane format`
    - Alternatively to ease your workflow, you can also add a git hook with:
      `cp tools/code-format-git-hook.sh .git/hooks/pre-commit`
2. Follow [Ray Wenderlich's coding style](https://github.com/raywenderlich/objective-c-style-guide).

## Tests

As much as possible, respect the ["Arrange, Act, Assert" convention](http://wiki.c2.com/?ArrangeActAssert) in the tests.

The tests in this project are organised according to the following conventions:
- Unit tests are located within the [UnitTests](CriteoPublisherSdk/Tests/UnitTests) directory.
- Integration tests are written in the [IntegrationTests](CriteoPublisherSdk/Tests/IntegrationTests) directory.
- The subset of integration tests which represent one of the functional tests defined [here](https://go.crto.in/publisher-sdk-functional-tests)
 are post-fixed with `FunctionTests`. The rest are post-fixed with `IntegrationTests`.

## Release

1. Bump version:
    - Releases: `bundle exec fastlane version_bump version:x.y.z`
    - For RCs use `version:x.y.z-rc1`
    - If you release several times the same `x.y.z` version, for instance several RCs, you have to
    bump bundle version, you can do this adding an extra `build:2` argument.
    e.g. `bundle exec fastlane version_bump version:x.y.z-rc2 build:2`
   
2. Ensure `CHANGELOG.md` is up to date and properly formatted:
    - Sections separated by lines `---` are used to split the changelog
    - The first section without version line will be used as Release description 
3. Check changes and submit a PR / merge if needed
4. Push a semver compliant version tag (`x.y.z` or `x.y.z-rc1`) to GitHub
    - That will trigger a [Test & Release to GitHub][ga-release-github] workflow
    - Check the result on [GitHub releases page][github-release]
5. Review the added GitHub release draft, publish it
6. Once published, it will trigger another [Release to CocoaPods][ga-release-cocoapods] workflow
that will push the spec to CocoaPods
7. Profit 🚀🥳

[github-release]: http://github.com/criteo/ios-publisher-sdk/releases
[ga-release-github]: https://github.com/criteo/ios-publisher-sdk/actions?query=workflow%3A%22Test+%26+Release+on+GitHub%22
[ga-release-cocoapods]: https://github.com/criteo/ios-publisher-sdk/actions?query=workflow%3A%22Release+on+CocoaPods%22
