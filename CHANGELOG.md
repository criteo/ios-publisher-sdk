# Criteo Publisher SDK Changelog
--------------------------------------------------------------------------------
## Version [5.0.0]

### Features
- MRAID 1.0 support.

--------------------------------------------------------------------------------
## Version [4.9.0]

### Features
- Bug fixing & performance improvements.

--------------------------------------------------------------------------------
## Version [4.8.0]

### Features
- Support simultaneously run multiple bid requests with the same ad unit.
- Updated Google-Mobile-Ads-SDK to v10.
- Disabled bitcode.
- Bumped min iOS version to iOS 12

--------------------------------------------------------------------------------
## Version [4.7.0]

### Features
- Xcode 14 support.

--------------------------------------------------------------------------------
## Version [4.6.0]

### Features
- Remove MoPub header bidding support
- Add ability to set Children's Online Privacy Protection Act ("COPPA") flag
- **Google Adapter**: Updating Google-Mobile-Ads-SDK to v9

### MoPub Adapter
- remove MoPub adapter support

--------------------------------------------------------------------------------
## Version 4.5.0

### Features
- **Google Ads**: add Rewarded ads support

### Fixes
- **In house**: allow init of `CRBannerView` without specifying the adUnitId

--------------------------------------------------------------------------------
## Version 4.4.0

### Features
- **Video ads**: Support VAST ads with Google and MoPub

--------------------------------------------------------------------------------
## Version 4.3.3

### Fixes
- **Google Adapter**: Fix #214 by restricting Google-Mobile-Ads-SDK to v8

--------------------------------------------------------------------------------
## Version 4.3.2

### Fixes
- #212: Fix crash on iOS 14.0

--------------------------------------------------------------------------------
## Version 4.3.1

### Fixes
- Google Ads SDK v8 support: Fix adapter

--------------------------------------------------------------------------------
## Version 4.3.0

### Features
- Google Ads SDK v8 support
- MoPub SDK v5.16 support

--------------------------------------------------------------------------------
## Version 4.2.1

### Fixes
- #198: Startup crash: 4.2.0 was removed from GitHub and CocoaPods
- #202: Crash with WebView deallocated on background thread

--------------------------------------------------------------------------------
## Version 4.2.0

### Features
- Add remote logging support.

### MoPub Adapter
- Add *Advanced native ads* support.

--------------------------------------------------------------------------------
## Version 4.1.0

### Features
- Add API to collect different levels of signals which will be used to bid based on context
- **Verbose logs**: You can now enable logs to diagnose Criteo Publisher SDK integration:
  - **API**: By calling `[Criteo setVerboseLogsEnabled:YES]`
  - **Launch Argument**: By adding `-CriteoPublisherSdkVerboseLogs` to launch arguments

### Fixes
- **In House**: `[Criteo loadBidForAdUnit:responseHandler:]` now calls `responseHandler` with nil as
  bid when a bid was not available, or when an error occurred, instead of a zero priced bid. 

--------------------------------------------------------------------------------
## Version 4.0.3

### Fixes
- **Xcode**: Update Xcode to 12.2 (and macOS to 11.0)

--------------------------------------------------------------------------------
## Version 4.0.2

### Fixes
- **Google Adapter**: Depend on Google SDK minor versions > 7.49

--------------------------------------------------------------------------------
## Version 4.0.1

### Features
- **In-House**: `CRBannerView`, `CRInterstitial`, `CRNativeLoader` can now be initialized without
  specifying an ad unit, as it is already provided in the bid loaded through `loadAdWithBid:`

--------------------------------------------------------------------------------
## Version 4.0.0

### Breaking changes
- **API**:
  - **New**: `[Criteo loadBidForAdUnit:responseHandler:]` loads asynchronously a bid from Criteo.
    This new method is intended for App Bidding and In-House SDK usage.
  - **App Bidding**: `[Criteo enrichAdObject:withBid:]` replaces `[Criteo setBidsForRequest:withAdUnit:]`:
    A bid is obtained using the aforementioned `loadBidForAdUnit:` method.
  - **In House**: `CRBannerView`, `CRInterstitial` and `CRNativeLoader` gets a ` loadAdWithBid:` that
    replaces former `loadAdWithBidToken:` methods. A bid is obtained using the aforementioned
    `loadBidForAdUnit:` method.
  - **`CRInterstitialDelegate`**:
    - `interstitialIsReadyToPresent:` moved to `interstitialDidReceiveAd:`.
      This method is now called when an interstitial ad is ready to be displayed.
    - `didFailToReceiveAdContentWithError:` merged into `didFailToReceiveAdWithError:`.
      This method is now called when an error occurs while requesting an interstitial ad.
- **CocoaPods**: Pod is now source provided rather than binary. Few potential changes required on
pod clients, you can:
  - Either add [`use_frameworks!`][use_frameworks] to your Podfile so CocoaPods produce frameworks
    from source as before, keeping the same imports working.
  - Either edit Sdk imports:
    - from `@import CriteoPublisherSdk;` _(Semantic import for frameworks)_
    - to `#import <CriteoPublisherSdk/CriteoPublisherSdk.h>` _(Standard CocoaPods imports)_
  - Alternatively, binary frameworks are now provided through [GitHub releases][gh_releases]
- **iOS 9** is now the minimum supported version of iOS _(bumped from iOS 8)_
- **Swift** we are including Swift code into the SDK, which means that if your project is Obj-C only,
  you now must have at least one `.swift` (even empty) file for Xcode to link against swift runtime.
- **Mediation Adapters**: These have been merged in this repository. For CocoaPods pods are now 
  declared as _subspecs_, meaning you have to edit your `Podfile`:
  - Google: From `CriteoGoogleMediationAdapters` to `CriteoPublisherSdk/GoogleAdapter`
  - MoPub: From `CriteoMoPubMediationAdapters` to `CriteoPublisherSdk/MoPubAdapter`

[gh_releases]: https://github.com/criteo/ios-publisher-sdk/releases
[use_frameworks]: https://guides.cocoapods.org/syntax/podfile.html#tab_use_frameworks_bang

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
