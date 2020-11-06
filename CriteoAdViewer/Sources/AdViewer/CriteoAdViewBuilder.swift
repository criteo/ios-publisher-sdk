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
  private let contextData: CRContextData

  init(controller: AdViewController, type: CriteoAdType) {
    logger = StandaloneLogger()
    logger.interstitialDelegate = controller
    adType = type
    contextData = CRContextData() /* TODO */
  }

  func build(config: AdConfig, criteo: Criteo) -> AdView {
    switch (config.adFormat, config.adUnit) {
    case (.sized(.banner, _), let adUnit as CRBannerAdUnit):
      return .banner(buildBanner(adUnit, criteo))
    case (.flexible(.interstitial), let adUnit as CRInterstitialAdUnit):
      return .interstitial(buildInterstitial(adUnit, criteo))
    case (.flexible(.native), let adUnit as CRNativeAdUnit):
      return .banner(buildNative(adUnit, criteo))
    case _:
      fatalError("Unsupported")
    }
  }

  private func buildBanner(_ adUnit: CRBannerAdUnit, _ criteo: Criteo) -> CRBannerView {
    let adView = CRBannerView(adUnit: adUnit, criteo: criteo)!
    adView.delegate = logger
    switch adType {
    case .standalone:
      adView.loadAd(withContext: contextData)
    case .inHouse:
      criteo.loadBid(for: adUnit, context: contextData){ maybeBid in
        if let bid = maybeBid {
          adView.loadAd(with: bid)
        }
      }
    }
    return adView
  }

  private func buildInterstitial(_ adUnit: CRInterstitialAdUnit, _ criteo: Criteo) -> CRInterstitial
  {
    let adView = CRInterstitial(adUnit: adUnit, criteo: criteo)!
    adView.delegate = logger
    switch adType {
    case .standalone:
      adView.loadAd(withContext: contextData)
    case .inHouse:
      criteo.loadBid(for: adUnit, context: contextData){ maybeBid in
        if let bid = maybeBid {
          adView.loadAd(with: bid)
        }
      }
    }
    return adView
  }

  private func buildNative(_ adUnit: CRNativeAdUnit, _ criteo: Criteo) -> AdvancedNativeView {
    let adView = AdvancedNativeView(adUnit: adUnit, criteo: criteo)
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
