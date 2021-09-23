//
//  MopubAdViewBuilder.swift
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

class MopubAdViewBuilder: AdViewBuilder {
  private let logger: MopubLogger
  private let keywords = "key1:value1,key2:value2"
  private let contextData: CRContextData

  init(
    controller: AdViewController,
    adUnitIdForAppInitialization: String
  ) {
    logger = MopubLogger(interstitialDelegate: controller)
    contextData = defaultContextData()

    // SDK Initialization
    let config = MPMoPubConfiguration(adUnitIdForAppInitialization: adUnitIdForAppInitialization)
    MoPub.sharedInstance().initializeSdk(with: config)
  }

  func build(config: AdConfig, criteo: Criteo, completion: (AdView) -> Void) {
    switch config.adFormat {
    case let .sized(.banner, size):
      completion(.banner(buildBanner(config: config, size: size, criteo: criteo)))
    case .flexible(.interstitial), .flexible(.video):
      completion(.interstitial(buildInterstitial(config: config, criteo: criteo)))
    case _:
      fatalError("Unsupported")
    }
  }

  // TODO: handle height properly
  private func mopubSize(size: AdSize) -> CGSize {
    switch size {
    case ._320x50: return CGSize(width: 320, height: 50)
    case ._300x250: return CGSize(width: 300, height: 250)
    }
  }

  private func buildBanner(config: AdConfig, size: AdSize, criteo: Criteo) -> MPAdView {
    let adView = MPAdView(adUnitId: config.adUnit.adUnitId)!
    adView.maxAdSize = mopubSize(size: size)
    adView.frame = CGRect(origin: CGPoint(), size: mopubSize(size: size))
    adView.keywords = keywords
    adView.delegate = logger
    load(adView, config: config, criteo: criteo)
    return adView
  }

  private func buildInterstitial(config: AdConfig, criteo: Criteo) -> MPInterstitialAdController {
    let adView = MPInterstitialAdController(forAdUnitId: config.adUnit.adUnitId)!
    adView.keywords = keywords
    adView.delegate = logger
    load(adView, config: config, criteo: criteo)
    return adView
  }

  private func load(_ ad: MPLoadableAd, config: AdConfig, criteo: Criteo) {
    let criteoAdUnitId: CRAdUnit
    if config.adFormat == .flexible(.video) {
        // need to use a specific adUnitId to be able to load video ads properly
      criteoAdUnitId = CRInterstitialAdUnit(
        adUnitId: "/140800857/Endeavour_InterstitialVideo_320x480")
    } else {
      criteoAdUnitId = config.adUnit
    }
    criteo.loadBid(for: criteoAdUnitId, withContext: contextData) { maybeBid in
      if let bid = maybeBid {
        criteo.enrichAdObject(ad, with: bid)
        ad.loadAd()
      }
    }
  }
}

protocol MPLoadableAd {
  func loadAd()
}

extension MPInterstitialAdController: InterstitialView, MPLoadableAd {
  func present(viewController: UIViewController) {
    show(from: viewController)
  }
}

extension MPAdView: MPLoadableAd {}
