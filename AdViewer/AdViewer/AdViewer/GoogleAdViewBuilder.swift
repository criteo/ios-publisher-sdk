//
// Created by Vincent Guerci on 11/03/2020.
// Copyright (c) 2020 Criteo. All rights reserved.
//

import GoogleMobileAds

class GoogleAdViewBuilder: AdViewBuilder {
    private let controller: AdViewController
    private let logger: GoogleDFPLogger

    init(controller: AdViewController) {
        self.controller = controller
        self.logger = GoogleDFPLogger(interstitialDelegate: controller)
    }

    func build(config: AdConfig, criteo: Criteo) -> AdView {
        switch config.adFormat {
        case .sized(.banner, let size):
            return .banner(buildBanner(config: config, size: googleAdSize(size: size), criteo: criteo))
        case .flexible(.native):
            return .banner(buildBanner(config: config, size: kGADAdSizeFluid, criteo: criteo))
        case .flexible(.interstitial):
            return .interstitial(buildInterstitial(config: config, criteo: criteo))
        case _:
            fatalError("Unsupported")
        }
    }

    private func loadAdView(criteo: Criteo, adUnit: CRAdUnit, load: (_ request: GADRequest?) -> ()) {
        let request = DFPRequest()
        criteo.setBidsForRequest(request, with: adUnit)
        load(request)
    }

    private func googleAdSize(size: AdSize) -> GADAdSize {
        switch (size) {
        case ._320x50: return kGADAdSizeBanner
        case ._300x250: return kGADAdSizeMediumRectangle
        }
    }

    private func buildBanner(config: AdConfig, size: GADAdSize, criteo: Criteo) -> DFPBannerView {
        let adUnit = config.adUnit
        let adView = DFPBannerView(adSize: size)
        adView.delegate = self.logger
        adView.adSizeDelegate = self.logger
        adView.adUnitID = adUnit.adUnitId
        adView.rootViewController = self.controller
        loadAdView(criteo: criteo, adUnit: adUnit, load: adView.load)
        return adView
    }

    private func buildInterstitial(config: AdConfig, criteo: Criteo) -> DFPInterstitial {
        let adUnit = config.adUnit
        let interstitial = DFPInterstitial(adUnitID: adUnit.adUnitId)
        interstitial.delegate = self.logger
        loadAdView(criteo: criteo, adUnit: adUnit, load: interstitial.load)
        return interstitial
    }
}

extension DFPInterstitial: InterstitialView {
    func present(viewController: UIViewController) {
        self.present(fromRootViewController: viewController)
    }
}