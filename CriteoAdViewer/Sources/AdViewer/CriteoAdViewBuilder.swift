//
//  CriteoAdViewBuilder.swift
//  CriteoAdViewer
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
