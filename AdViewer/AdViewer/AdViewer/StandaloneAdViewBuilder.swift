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
        switch (config.adFormat) {
        case .sized(.banner, _):
            return .banner(buildBanner(adUnit: config.adUnit, criteo: criteo))
        case .flexible(.interstitial):
            return .interstitial(buildInterstitial(adUnit: config.adUnit, criteo: criteo))
        case _:
            fatalError("Unsupported")
        }
    }

    private func buildBanner(adUnit: CRAdUnit, criteo: Criteo) -> CRBannerView {
        let adView = CRBannerView(adUnit: adUnit as? CRBannerAdUnit, criteo: criteo)!
        adView.delegate = logger
        adView.loadAd()
        return adView
    }

    private func buildInterstitial(adUnit: CRAdUnit, criteo: Criteo) -> CRInterstitial {
        let adView = CRInterstitial(adUnit: adUnit as? CRInterstitialAdUnit, criteo: criteo)!
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