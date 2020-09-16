# Criteo Publisher SDK Changelog
--------------------------------------------------------------------------------
## Version 4.0.0

### Breaking changes
- **CocoaPods**: Pod is now source provided rather than binary. Few potential changes required on
pod clients, you can:
  - Either add [`use_frameworks!`][use_frameworks] to your Podfile so CocoaPods produce frameworks
    from source as before, keeping the same imports working.
  - Either edit Sdk imports:
    - from `@import CriteoPublisherSdk;` _(Semantic import for frameworks)_
    - to `#import <CriteoPublisherSdk/CriteoPublisherSdk.h>` _(Standard CocoaPods imports)_
  - Alternatively, binary frameworks are now provided through [GitHub releases][gh_releases]
- **iOS 9** is now the minimum supported version of iOS _(bumped from iOS 8)_
- **Mediation Adapters**: These have been merged in this repository. For CocoaPods pods are now 
  declared as _subspecs_, meaning you have to edit your `Podfile`:
  - Google: From `CriteoGoogleMediationAdapters` to `CriteoPublisherSdk/GoogleAdapter`
  - MoPub: From `CriteoMoPubMediationAdapters` to `CriteoPublisherSdk/MoPubAdapter`

[gh_releases]: https://github.com/criteo/ios-publisher-sdk/releases
[use_frameworks]: https://guides.cocoapods.org/syntax/podfile.html#tab_use_frameworks_bang
--------------------------------------------------------------------------------
## Version Next

### Features
- GDPR: Disable performance metrics when TCF v2 consent is not given for purposes 1 or 7
--------------------------------------------------------------------------------
## Version 3.10.0

### Features
- GAM App-Bidding: Support sub classes of GAM objects: `DFPRequest`, `GADRequest`, ...
- MoPub App-Bidding: Support sub classes of `MPAdView` and `MPInterstitialAdController`.
- Server Side bidding: `loadAdWithDisplayData` added to `CRBannerView` and `CRInterstitial`
--------------------------------------------------------------------------------
## Version 3.9.0

### Features
- Consider safe area when displaying interstitial Ads for Standalone, In-House, MoPub AppBidding and
  mediation adapters. DFP and Custom AppBidding are still always fullscreen.
--------------------------------------------------------------------------------
## Version 3.8.0

### Features
- Provide legal privacy text for native in `CriteoNativeAd.legalText`

### MoPub Adapter
 - Mopub SDK v5.13 support:
   - Has breaking changes that are not backward compatible
   - Requires Mopub >= 5.13 and as a consequence iOS 10
--------------------------------------------------------------------------------
## Version 3.7.0

### Features
- *Advanced native ads* public release; integration instructions and documentation available on our
  [support website](https://publisherdocs.criteotilt.com/app/ios/)
--------------------------------------------------------------------------------
## Version 3.6.1

### Bug fixes
- Improve Criteo instance initialization reliability
--------------------------------------------------------------------------------
## Version 3.6.0

### Features
- Insert `crt_size` keywords for DFP, MoPub and Custom Header-Bidding integration banner
- Insert `crt_size` keywords for DFP Header-Bidding integration on interstitial

### Bug fixes
- Fix issue related to `WKWebView`
--------------------------------------------------------------------------------
## Version 3.4.1

### MoPub Adapter
- Update the Criteo Publisher SDK with the Mopub's consent
--------------------------------------------------------------------------------
