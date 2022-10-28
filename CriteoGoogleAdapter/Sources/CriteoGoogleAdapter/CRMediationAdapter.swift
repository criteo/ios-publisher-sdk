//
//  CRMediationAdapter.swift
//  CriteoGoogleAdapter
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

import CriteoPublisherSdk
import GoogleMobileAds
import Foundation


class CRMediationAdapter: NSObject {


  // MARK: - Variables

  var banner: CRBannerView?
  // weak var delegate: GADMediationInterstitialAdEventDelegate?

  weak var delegateBanner: CRBannerViewDelegate?
  weak var delegateInterstitial: CRInterstitialDelegate?
//  weak war delegateNative: NativeDelegate? // TODO: Implement or remove this

  var interstitial: CRInterstitial?


  // MARK: - Life Cycle

  required override init() {
    super.init()
  }
}


// MARK: - GADMediationAdapter

extension CRMediationAdapter: GADMediationAdapter {

  static func adapterVersion() -> GADVersionNumber {
    return GADVersionNumber(majorVersion: 1, minorVersion: 1, patchVersion: 1) // TODO: Return Criteo version
  }

  static func adSDKVersion() -> GADVersionNumber {
    return GADVersionNumber(majorVersion: 1, minorVersion: 1, patchVersion: 1) // TODO: Return Criteo version
  }

  static func networkExtrasClass() -> GADAdNetworkExtras.Type? {
    return nil
  }

  func loadBanner(for adConfiguration: GADMediationBannerAdConfiguration, completionHandler: @escaping GADMediationBannerLoadCompletionHandler) {

    // TODO: Extract this if let to separate ticket DPP-4127 https://criteo.atlassian.net/browse/DPP-4127
    if let childDirectedTreatment = adConfiguration.childDirectedTreatment {
      Criteo.shared().childDirectedTreatment = childDirectedTreatment
    }

    let adUnit = CRBannerAdUnit(gadMediationBannerAdConfiguration: adConfiguration)
    Criteo.shared().registerPublisherId("", with: [adUnit]) // TODO: Find a way to get criteoPublisherId
    banner = banner ?? CRBannerView(adUnit: adUnit)
    banner?.delegate = delegateBanner
    banner?.loadAd()
  }

  func loadInterstitial(for adConfiguration: GADMediationInterstitialAdConfiguration, completionHandler: @escaping GADMediationInterstitialLoadCompletionHandler) {

    // TODO: Extract this if let to separate ticket DPP-4127 https://criteo.atlassian.net/browse/DPP-4127
    if let childDirectedTreatment = adConfiguration.childDirectedTreatment {
      Criteo.shared().childDirectedTreatment = childDirectedTreatment
    }

    let adUnit = CRInterstitialAdUnit(gadMediationInterstitialAdConfiguration: adConfiguration)
    Criteo.shared().registerPublisherId("", with: [adUnit]) // TODO: Find a way to get criteoPublisherId
    interstitial = interstitial ?? CRInterstitial(adUnit: adUnit)
    interstitial?.delegate = delegateInterstitial
    interstitial?.loadAd()
  }

  func loadNativeAd(for adConfiguration: GADMediationNativeAdConfiguration, completionHandler: @escaping GADMediationNativeLoadCompletionHandler) {

    // TODO: Extract this if let to separate ticket DPP-4127 https://criteo.atlassian.net/browse/DPP-4127
    if let childDirectedTreatment = adConfiguration.childDirectedTreatment {
      Criteo.shared().childDirectedTreatment = childDirectedTreatment
    }

    // TODO: Maybe add support for native ads? or remove this function
  }
}
