//
// Created by Vincent Guerci on 11/03/2020.
// Copyright (c) 2020 Criteo. All rights reserved.
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
        switch (adFormat.type, adFormat.size) {
        case (.banner, .some(let size)):
            return CRBannerAdUnit(adUnitId: adUnitId, size: size.cgSize())
        case (.native, _):
            return CRNativeAdUnit(adUnitId: adUnitId)
        case (.interstitial, _):
            return CRInterstitialAdUnit(adUnitId: adUnitId)
        case (_, _):
            fatalError("Unsupported")
        }
    }
}
