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
- Unit tests are located within the [test](src/test/) directory.
- Integration tests are written in the [Integration directory](/pubsdkTests/IntegrationTests)
- The subset of integration tests which represent one of the functional tests defined [here](https://confluence.criteois.com/display/EE/Functional+Tests)
 are post-fixed with `FunctionTests`. The rest are post-fixed with `IntegrationTests`.


# How to release the publisher SDK on Cocapods?

Well it's just a podspec file: It is available in the repository pub-sdk/fuji/CriteoPublisherSdk.podspec

* [Install azure command line tools](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-macos?view=azure-cli-latest)
* Zip the CriteoPublisherSdk.framework folder along with the LICENSE file in a file named CriteoPublisherSdk_iOS_vX.X.X.Release.zip (replace X.X.X by version number, please). It should be at the root. Like this zip file. LICENSE file is also available in pub-sdk/fuji/LICENSE
* Upload that to azure. You can use the azureDeploy.sh script, it contains the credentials, you need to input the actual version number Please. say,     ./azureDeploy.sh 3.2.0
* Ok, so now you have a public URL that serves the compile the pubsdk framework. How cool is that? Verify that it works by using this URL: https://pubsdk-bin.criteo.com/publishersdk/ios/CriteoPublisherSdk_iOS_v3.1.0.Release.zip (did I mention you should replace 3.1.0 by the version number ?)
* If this didn't work, sorry but you're going to have to figure out what went wrong, and then fix it.
* If it did work, then great! You can now update the .podspec file above. Just change the s.source url and the s.version, and you should be good.
* Now you can validate the podpsect by running pod spec lint CriteoPublisherSdk.podspec
* If this didn't work, sorry but you're going to have to figure out what went wrong, and then fix it.
* If this did work, then you can publish the publisher SDK! Run pod trunk push CriteoPublisherSdk.podspec
* It may ask you to validate your email or something... The email of the owner is Endeavour@criteo.com
