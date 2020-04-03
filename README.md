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

# How to release the publisher SDK

## Create a release candidate

* Bump to a new version and push to git on master
    Android: see https://review.crto.in/#/c/610468/
    iOS: see https://review.crto.in/#/c/610471/
* From Gerrit or from your terminal create a new tag (e.g v3_2_1_RC1)
* Update the constants at the top of `scripts/generate_release_candidate.sh` and then launch it.
* Upload the resulting frameworks to the [release page](https://confluence.criteois.com/display/PUBSDK/Releases)
* Launch Xcode with the testing app clone done by `generate_release_candidate.sh`, create an archive and push it to the iTunes Connect
* Go in [iTunes Connect](https://itunesconnect.apple.com/) and ensure that the new version of the testing app is pushed to the testers via Testflight

## Push a validated release candidate to CocoaPods

* Rub `./scripts/setup.sh` if not alreay done for using Azure CLI.
* Zip the CriteoPublisherSdk.framework folder along with the LICENSE file in a file named CriteoPublisherSdk_iOS_vX.X.X.Release.zip (replace X.X.X by version number, please). It should be at the root. Like this zip file. LICENSE file is also available in pub-sdk/fuji/LICENSE
* Run `./scripts/azureDeploy.sh <Release version>`
* Update the podspect accordly to the release version and with the new URL for the release on Azure (e.g https://pubsdk-bin.criteo.com/publishersdk/ios/CriteoPublisherSdk_iOS_v3.1.0.Release.zip)
* Run `pod spec lint CriteoPublisherSdk.podspec` to validate the podspec
* Run `pod trunk push CriteoPublisherSdk.podspec` to push the podspec to CocoaPods
