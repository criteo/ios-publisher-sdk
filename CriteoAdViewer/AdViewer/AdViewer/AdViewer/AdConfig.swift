//
// Copyright © 2018-2020 Criteo. All rights reserved.
//

struct AdConfig {
    let publisherId: String
    let adUnit: CRAdUnit
    let adFormat: AdFormat

    init(publisherId: String, adUnitId: String, adFormat: AdFormat) {
        self.publisherId = publisherId
        self.adUnit = AdConfig.buildAdUnit(adFormat: adFormat, adUnitId: adUnitId)
        self.adFormat = adFormat
    }

    private static func buildAdUnit(adFormat: AdFormat, adUnitId: String) -> CRAdUnit {
        switch (adFormat) {
        case .sized(.banner, let size):
            return CRBannerAdUnit(adUnitId: adUnitId, size: size.cgSize())
        case .flexible(.native):
            return CRNativeAdUnit(adUnitId: adUnitId)
        case .flexible(.interstitial):
            return CRInterstitialAdUnit(adUnitId: adUnitId)
        case _:
            fatalError("Unsupported")
        }
    }
}
