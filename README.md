#  README

## General practices

Follow the Robert Martin suggestion about [Clean Code](https://gist.github.com/wojteklu/73c6914cc446146b8b533c0988cf8d29).

## Coding Style

There is a lack of coherency in the code base regarding the coding style. The cameleon style must not be applied here. All code that you touch must respect the following [Ray Wenderlich's coding style](https://github.com/raywenderlich/objective-c-style-guide).


## Testing

### Testing style
As much as possible, respect the ["Arrange, Act, Assert" convention](http://wiki.c2.com/?ArrangeActAssert) in the tests.

### Test organisation
The tests in this project are organised according to the following convention:
- Unit tests are located within the [UnitTests](pubsdk/Tests/UnitTests) directory
- Integration tests are written in the [IntegrationTests](pubsdk/Tests/IntegrationTests) directory
- The subset of integration tests which represent one of the functional tests defined [here](https://confluence.criteois.com/display/EE/Functional+Tests)
 are post-fixed with `FunctionTests`. The rest are post-fixed with `IntegrationTests`.

### Getting ads on iOS Simulator
- Starting iOS 13, the simulators sends zero-ed IDFAs, a simple workaround is to use an older iOS version
- To have a Valuable profile in order to get bids, for this you can:
    - Use the [Get retargeted](https://chrome.google.com/webstore/detail/get-retargeted/lkfglidpccbhmpgpekfbkidncpinjobl) Chrome extension with your IDFA
    - Use Mobile Safari on a publisher website such as laredoute.fr, browsing its catalog and adding products to your cart

### Testing against a local CDB

When working in debug environment, the SDK hits the preprod of CDB. To test integration with CDB,
you can make the SDK hit a local instance of CDB instead. You need to:

- Checkout the CDB project:

```shell
cd ~ && \
mkdir -p publisher/direct-bidder && \
cd publisher/direct-bidder && \
gradle initWorkspace && \
./gradlew checkout --project=publisher/direct-bidder
```

- Follow instructions in `README.md` to start the server (either in debug or not)
- Uncomment the `#define HIT_LOCAL_CDB` line in the `CR_Config.m` file.

### Testing against several device types & runtimes

We might want to automate this at some point, but that requires additional runtimes to be installed,
which requires actions on jenkins slaves. For now we can do this manually:
After downloading runtimes from Xcode, create some test simulators:
```shell
xcrun simctl create "Fuji Simulator 5s10.3" com.apple.CoreSimulator.SimDeviceType.iPhone-5s com.apple.CoreSimulator.SimRuntime.iOS-10-3
xcrun simctl create "Fuji Simulator 7P11.4" com.apple.CoreSimulator.SimDeviceType.iPhone-7-Plus com.apple.CoreSimulator.SimRuntime.iOS-11-4
xcrun simctl create "Fuji Simulator XS12.4" com.apple.CoreSimulator.SimDeviceType.iPhone-XS com.apple.CoreSimulator.SimRuntime.iOS-12-4
```
Then run tests, in parallel can help, but expect flaky tests to fail
```shell
XCODEBUILD_SCHEME_FOR_TESTING="pubsdk"; \
CRITEO_CONFIGURATION="Release"; \
CRITEO_SIM_ARCHS='i386 x86_64'; \
xcodebuild \
-workspace fuji.xcworkspace \
    -scheme "${XCODEBUILD_SCHEME_FOR_TESTING}" \
    -configuration $CRITEO_CONFIGURATION \
    -IDEBuildOperationMaxNumberOfConcurrentCompileTasks=`sysctl -n hw.ncpu` \
    -derivedDataPath build/DerivedData  \
    -parallel-testing-enabled YES \
    -sdk iphonesimulator \
    -destination "platform=iOS Simulator,name=Fuji Simulator 5s10.3,OS=10.3.1" \
    -destination "platform=iOS Simulator,name=Fuji Simulator 7P11.4,OS=11.4" \
    -destination "platform=iOS Simulator,name=Fuji Simulator XS12.4,OS=12.4" \
    ARCHS="$CRITEO_SIM_ARCHS" \
    VALID_ARCHS="$CRITEO_SIM_ARCHS" \
    ONLY_ACTIVE_ARCH=NO \
    clean build test
```

# How to release the publisher SDK

## Create a release candidate

* Push a version bump to Gerrit:
    * [fuji](https://review.crto.in/659643)
    * [fuji-test-app](https://review.crto.in/659663)
* From Gerrit or from your terminal create a new tag (e.g v3_5_0_RC1)
* Update the constants at the top of `scripts/generate_release_candidate.sh` and then launch it. This will open Xcode on test app project with the SDK RC, and Finder on the folder containing Frameworks:
    * Upload frameworks to the [release page](https://confluence.criteois.com/display/PUBSDK/Releases)
    * From Xcode create an archive and push it to iTunes Connect, "Distribute through the App Store"
* Go in [iTunes Connect](https://itunesconnect.apple.com/)
    * Push to the testers via Testflight the new version of the testing app

## Push a validated release candidate to CocoaPods

* Rub `./scripts/setup.sh` if not alreay done for using Azure CLI.
* Zip the CriteoPublisherSdk.framework folder along with the LICENSE file in a file named CriteoPublisherSdk_iOS_vX.X.X.Release.zip (replace X.X.X by version number, please). It should be at the root. Like this zip file. LICENSE file is also available in pub-sdk/fuji/LICENSE
* Run `./scripts/azureDeploy.sh <Release version>`
* Update the podspect accordly to the release version and with the new URL for the release on Azure (e.g https://pubsdk-bin.criteo.com/publishersdk/ios/CriteoPublisherSdk_iOS_v3.1.0.Release.zip)
* Run `pod spec lint CriteoPublisherSdk.podspec` to validate the podspec
* Run `pod trunk push CriteoPublisherSdk.podspec` to push the podspec to CocoaPods
