//
//  GAMAdViewBuilder.swift
//  CriteoAdViewer
//
//  Copyright © 2018-2022 Criteo. All rights reserved.
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

import Foundation
import GoogleMobileAds

class GAMAdViewBuilder: AdViewBuilder {
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
        .banner(buildBanner(config: config, size: googleAdSize(size: size))))
    case .flexible(.interstitial):
      buildInterstitial(config: config, completion: completion)
    default: break
    }
  }

  private func buildBanner(config: AdConfig, size: GADAdSize) -> GADBannerView {
    let adView = GADBannerView(adSize: size)
    adView.delegate = self.logger
    adView.adSizeDelegate = self.logger
    adView.adUnitID = config.externalAdUnitId
    adView.rootViewController = self.controller
    adView.load(GADRequest())
    return adView
  }

  private func googleAdSize(size: AdSize) -> GADAdSize {
    switch size {
    case .size320x50: return GADAdSizeBanner
    case .size300x250: return GADAdSizeMediumRectangle
    }
  }

  private func buildInterstitial(config: AdConfig, completion: @escaping (AdView) -> Void) {
    let request = GADRequest()
    GADInterstitialAd.load(
      withAdUnitID: config.externalAdUnitId,
      request: request
    ) { [weak self] ad, error in
      if let error = error {
        print("Failed to load interstitial ad with error: \(error.localizedDescription)")
        return
      }
      if let ad = ad {
        ad.fullScreenContentDelegate = self?.logger
        completion(.interstitial(ad))
      }
    }
  }
}
