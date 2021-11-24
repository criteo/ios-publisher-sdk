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
  private let contextData: CRContextData

  init(controller: AdViewController) {
    self.controller = controller
    self.logger = GoogleDFPLogger(interstitialDelegate: controller)
    self.contextData = defaultContextData()
  }

  func build(config: AdConfig, criteo: Criteo, completion: @escaping (AdView) -> Void) {
    switch config.adFormat {
    case .sized(.banner, let size):
      completion(
        .banner(buildBanner(config: config, size: googleAdSize(size: size), criteo: criteo)))
    case .flexible(.native):
      completion(.banner(buildBanner(config: config, size: kGADAdSizeFluid, criteo: criteo)))
    case .flexible(.interstitial), .flexible(.video):
      buildInterstitial(config: config, criteo: criteo, completion: completion)
    case .flexible(.rewarded):
      buildRewarded(config: config, criteo: criteo, completion: completion)
    case _:
      fatalError("Unsupported")
    }
  }

  private func loadAdView(
    criteo: Criteo, adUnit: CRAdUnit, load: @escaping (_ request: GAMRequest?) -> Void
  ) {
    criteo.loadBid(for: adUnit, withContext: contextData) { maybeBid in
      let request: GAMRequest? = maybeBid.map { bid in
        let request = GAMRequest()
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

  private func buildBanner(config: AdConfig, size: GADAdSize, criteo: Criteo) -> GAMBannerView {
    let adUnit = config.adUnit
    let adView = GAMBannerView(adSize: size)
    adView.delegate = self.logger
    adView.adSizeDelegate = self.logger
    adView.adUnitID = adUnit.adUnitId
    adView.rootViewController = self.controller
    loadAdView(criteo: criteo, adUnit: adUnit, load: adView.load)
    return adView
  }

  private func buildInterstitial(
    config: AdConfig, criteo: Criteo, completion: @escaping (AdView) -> Void
  ) {
    let adUnit = config.adUnit

    loadAdView(criteo: criteo, adUnit: adUnit) { request in
      GAMInterstitialAd.load(withAdManagerAdUnitID: adUnit.adUnitId, request: request) {
        maybeAd, maybeError in
        if let error = maybeError {
          print("Failed to load interstitial ad with error: \(error.localizedDescription)")
        }
        if let ad = maybeAd {
          ad.fullScreenContentDelegate = self.logger
          completion(.interstitial(ad))
        }
      }
    }
  }

  private func buildRewarded(
    config: AdConfig, criteo: Criteo, completion: @escaping (AdView) -> Void
  ) {
    let adUnit = config.adUnit
    loadAdView(criteo: criteo, adUnit: adUnit) { request in
      GADRewardedAd.load(withAdUnitID: adUnit.adUnitId, request: request) {
        maybeAd, maybeError in
        if let error = maybeError {
          print("Failed to load rewarded ad with error: \(error.localizedDescription)")
        }
        if let ad = maybeAd {
          ad.fullScreenContentDelegate = self.logger
          completion(.interstitial(ad))
        }
      }
    }
  }
}

extension GAMInterstitialAd: InterstitialView {
  func present(viewController: UIViewController) {
    self.present(fromRootViewController: viewController)
  }
}

extension GADRewardedAd: InterstitialView {
  func present(viewController: UIViewController) {
    self.present(
      fromRootViewController: viewController,
      userDidEarnRewardHandler: {
        print("User did earn reward \(self.adReward)")
      })
  }
}
