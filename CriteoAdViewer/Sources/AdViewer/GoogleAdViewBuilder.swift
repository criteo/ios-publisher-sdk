//
//  GoogleAdViewBuilder.swift
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

  private func loadAdView(
    criteo: Criteo, adUnit: CRAdUnit, load: @escaping (_ request: GADRequest?) -> Void
  ) {
    criteo.loadBid(for: adUnit) { maybeBid in
      let request: GADRequest? = maybeBid.map { bid in
        let request = DFPRequest()
        criteo.enrichAdObject(request, with: bid)
        return request
      }
      return load(request)
    }
  }

  private func googleAdSize(size: AdSize) -> GADAdSize {
    switch size {
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
