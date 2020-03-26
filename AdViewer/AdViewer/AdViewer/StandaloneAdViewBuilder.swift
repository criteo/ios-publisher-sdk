//
// Created by Vincent Guerci on 26/03/2020.
// Copyright (c) 2020 Criteo. All rights reserved.
//

class StandaloneAdViewBuilder: AdViewBuilder {
    private let logger: StandaloneLogger

    init(controller: AdViewController) {
        self.logger = StandaloneLogger(interstitialDelegate: controller)
    }

    func build(config: AdConfig, criteo: Criteo) -> AdView {
        switch (config.adFormat.type) {
        case .banner:
            return .banner(buildBanner(adUnit: config.adUnit))
        case .interstitial:
            return .interstitial(buildInterstitial(adUnit: config.adUnit))
        case _:
            fatalError("Unsupported")
        }
    }

    private func buildBanner(adUnit: CRAdUnit) -> CRBannerView {
        let adView = CRBannerView(adUnit: adUnit as! CRBannerAdUnit)
        adView.delegate = logger
        adView.loadAd()
        return adView
    }

    private func buildInterstitial(adUnit: CRAdUnit) -> CRInterstitial {
        let adView = CRInterstitial(adUnit: adUnit as! CRInterstitialAdUnit)
        adView.delegate = logger
        adView.loadAd()
        return adView
    }
}

extension CRInterstitial: InterstitialView {
    func present(viewController: UIViewController) {
        self.present(fromRootViewController: viewController)
    }
}