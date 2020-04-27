# Criteo Direct Bidder for MoPub Mediation

## Version management

For now, the Mopub Adapter follows the Criteo Publisher SDK. It means that when we bump the SDK, we also bump the Adaptor. If the SDK version is 3.5.0, the adaptor version is 3.5.0.0 so that we can bump the last digit independantly.

You need to update:
- the MARKETING_VERSION
- the podspec
- the CRCriteoAdapterConfiguration.m

## Publication

The classes of [this project is open-source](https://github.com/criteo/ios-publisher-sdk-mopub-adapters.git).
It is also published on [CocoaPods](https://cocoapods.org/pods/CriteoMoPubMediationAdapters).

To publish you can use the scripts of the project.

### Publication on Github

The following script will prepare the publication:

    ./scripts/prepare_publication_on_github.sh <new version> "<Commit message>"

Example:

    ./scripts/prepare_publication_on_github.sh 3.4.1.0 "Set MoPub's consent into the Criteo Publisher SDK"

Then you need to go in the created directory, review the result and push if it fits you.
For that check the command suggested by the script and don't forget to push the new tag. 

### Publication on Cocoapods

The following script will push the new version on Cocoapods:

    ./scripts/publish_on_cocoapods.sh