# Criteo Publisher SDK Changelog
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
