//
// Copyright © 2018-2020 Criteo. All rights reserved.
//

enum CriteoAdType {
    case standalone, inHouse
}

class CriteoAdViewBuilder: AdViewBuilder {
    private let logger: StandaloneLogger
    private let adType: CriteoAdType

    init(controller: AdViewController, type: CriteoAdType) {
        logger = StandaloneLogger()
        logger.interstitialDelegate = controller
        adType = type
    }

    func build(config: AdConfig, criteo: Criteo) -> AdView {
        switch (config.adFormat) {
        case .sized(.banner, _):
            return .banner(buildBanner(adUnit: config.adUnit, criteo: criteo))
        case .flexible(.interstitial):
            return .interstitial(buildInterstitial(adUnit: config.adUnit, criteo: criteo))
        case .flexible(.native):
            return .banner(buildNative(adUnit: config.adUnit, criteo: criteo))
        case _:
            fatalError("Unsupported")
        }
    }

    private func buildBanner(adUnit: CRAdUnit, criteo: Criteo) -> CRBannerView {
        let adView = CRBannerView(adUnit: adUnit as? CRBannerAdUnit, criteo: criteo)!
        adView.delegate = logger
        switch adType {
        case .standalone:
            adView.loadAd()
        case .inHouse:
            let bidResponse = criteo.getBidResponse(for: adUnit)
            adView.loadAd(with: bidResponse.bidToken)
        }
        return adView
    }

    private func buildInterstitial(adUnit: CRAdUnit, criteo: Criteo) -> CRInterstitial {
        let adView = CRInterstitial(adUnit: adUnit as? CRInterstitialAdUnit, criteo: criteo)!
        adView.delegate = logger
        switch adType {
        case .standalone:
            adView.loadAd()
        case .inHouse:
            let bidResponse = criteo.getBidResponse(for: adUnit)
            adView.loadAd(with: bidResponse.bidToken)
        }
        return adView
    }

    private func buildNative(adUnit: CRAdUnit, criteo: Criteo) -> AdvancedNativeView {
        let adView = AdvancedNativeView(adUnit: adUnit as! CRNativeAdUnit, criteo: criteo)
        adView.delegate = logger
        switch adType {
        case .standalone:
            adView.loadAd()
        case .inHouse:
            //InHouse is not supported on Native > Act as Standalone
            adView.loadAd()
        }
        return adView
    }
}

extension CRInterstitial: InterstitialView {
    func present(viewController: UIViewController) {
        self.present(fromRootViewController: viewController)
    }
}
