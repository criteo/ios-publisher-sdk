//
// Created by Vincent Guerci on 11/03/2020.
// Copyright (c) 2020 Criteo. All rights reserved.
//

class MopubAdViewBuilder: AdViewBuilder {
    private let logger: MopubLogger
    private let keywords = "key1:value1,key2:value2"

    init(controller: AdViewController,
         adUnitIdForAppInitialization: String) {
        self.logger = MopubLogger(interstitialDelegate: controller)

        // SDK Initialization
        let config = MPMoPubConfiguration(adUnitIdForAppInitialization: adUnitIdForAppInitialization)
        MoPub.sharedInstance().initializeSdk(with: config)
    }

    func build(config: AdConfig, criteo: Criteo) -> AdView {
        let format = config.adFormat
        switch (format.type, format.size) {
        case (.banner, .some(let size)):
            return .banner(buildBanner(adUnit: config.adUnit, size: size, criteo: criteo))
        case (.interstitial, _):
            return .interstitial(buildInterstitial(adUnit: config.adUnit, criteo: criteo))
        case (_, _):
            fatalError("Unsupported")
        }
    }

    private func mopubSize(size: AdSize) -> CGSize {
        switch (size) {
        case ._320x50: return MOPUB_BANNER_SIZE
        case ._300x250: return MOPUB_MEDIUM_RECT_SIZE
        }
    }

    private func buildBanner(adUnit: CRAdUnit, size: AdSize, criteo: Criteo) -> MPAdView {
        let adView = MPAdView(adUnitId: adUnit.adUnitId, size: mopubSize(size: size))!
        adView.keywords = keywords
        criteo.setBidsForRequest(adView, with: adUnit)
        adView.delegate = self.logger
        adView.loadAd()
        return adView
    }

    private func buildInterstitial(adUnit: CRAdUnit, criteo: Criteo) -> MPInterstitialAdController {
        let adView = MPInterstitialAdController(forAdUnitId: adUnit.adUnitId)!
        adView.keywords = keywords
        criteo.setBidsForRequest(adView, with: adUnit)
        adView.delegate = self.logger
        adView.loadAd()
        return adView
    }
}

extension MPInterstitialAdController: InterstitialView {
    func present(viewController: UIViewController) {
        self.show(from: viewController)
    }
}