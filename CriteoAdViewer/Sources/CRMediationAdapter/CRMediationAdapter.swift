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

class CRCustomEvent: NSObject, CRCOPPAIntegration {
    // MARK: - Variables
    /// The Banner ad
    var bannerView: CRBannerView?
    /// The ad event delegate to forward ad rendering events to the Google Mobile Ads SDK.
    var bannerDelegate: GADMediationBannerAdEventDelegate?
    /// Completion handler called after ad load
    var bannerCompletionHandler: GADMediationBannerLoadCompletionHandler?
    /// Interstitial ad
    var interstitial: CRInterstitial?
    /// The ad event delegate to forward ad rendering events to the Google Mobile Ads SDK.
    var interstitialDelegate: GADMediationInterstitialAdEventDelegate?
    /// Completion handler called after ad load
    var interstitialCompletionHandler: GADMediationInterstitialLoadCompletionHandler?

    // MARK: - Life Cycle
    required override init() {
        debugPrint(#function)
        super.init()
    }
}

// MARK: - GADMediationAdapter
extension CRCustomEvent: GADMediationAdapter {
    static func adapterVersion() -> GADVersionNumber {
        return GADVersionNumber(with: CRITEO_PUBLISHER_SDK_VERSION)
    }

    static func adSDKVersion() -> GADVersionNumber {
        return GADVersionNumber(with: CRITEO_PUBLISHER_SDK_VERSION)
    }

    static func networkExtrasClass() -> GADAdNetworkExtras.Type? {
        return nil
    }

    static func setUpWith(_ configuration: GADMediationServerConfiguration,
                          completionHandler: @escaping GADMediationAdapterSetUpCompletionBlock) {
        completionHandler(nil)
    }

    func loadBanner(for adConfiguration: GADMediationBannerAdConfiguration,
                    completionHandler: @escaping GADMediationBannerLoadCompletionHandler) {
        /// Set child directed tratment flag to Criteo SDK
        set(childDirectedTreatment: adConfiguration)
        /// Extract CR params from ad configuration.
        guard let params = CRServerParams(with: adConfiguration.credentials) else {
            let error = NSError(domain: GADErrorDomain,
                                code: GADErrorCode.noFill.rawValue,
                                userInfo: [NSLocalizedDescriptionKey: "Missing ad configuration credentials"])
            bannerDelegate = completionHandler(nil, error)
            return
        }
        /// Create ad unit id
        let adUnit = CRBannerAdUnit(adUnitId: params.adUnitId,
                                    size: adConfiguration.adSize.size)
        /// Register ad unit to Criteo SDK
        Criteo.shared().registerPublisherId(params.publisherId, with: [adUnit])
        /// Intantiate Banner Ad
        if bannerView == nil {
            bannerView = CRBannerView(adUnit: adUnit)
        }

        self.bannerCompletionHandler = completionHandler
        bannerView?.delegate = self
        bannerView?.loadAd()
    }

    func loadInterstitial(for adConfiguration: GADMediationInterstitialAdConfiguration,
                          completionHandler: @escaping GADMediationInterstitialLoadCompletionHandler) {
        /// Set child directed tratment flag to Criteo SDK
        set(childDirectedTreatment: adConfiguration)

        /// Extract CR params from ad configuration.
        guard let params = CRServerParams(with: adConfiguration.credentials) else {
            let error = NSError(domain: GADErrorDomain,
                                code: GADErrorCode.noFill.rawValue,
                                userInfo: [NSLocalizedDescriptionKey: "Missing ad configuration credentials"])
            interstitialDelegate = completionHandler(nil, error)
            return
        }
        /// Create ad unit id
        let adUnit = CRInterstitialAdUnit(adUnitId: params.adUnitId)
        /// Register ad unit to Criteo SDK
        Criteo.shared().registerPublisherId(params.publisherId, with: [adUnit])
        /// Intantiate Interstitial Ad
        if interstitial == nil {
            interstitial = CRInterstitial(adUnit: adUnit)
        }
        /// set the completion handler reference
        self.interstitialCompletionHandler = completionHandler
        self.interstitial?.delegate = self
        self.interstitial?.loadAd()
    }
}


// MARK: - GADMediationInterstitialAd implementation
extension CRCustomEvent: GADMediationInterstitialAd {
    func present(from viewController: UIViewController) {
        guard let ad = interstitial, ad.isAdLoaded else { return }
        ad.present(fromRootViewController: viewController)
    }
}

// MARK: - CRInterstitialDelegate implementation
extension CRCustomEvent: CRInterstitialDelegate {
    func interstitialDidReceiveAd(_ interstitial: CRInterstitial!) {
        guard let handler = interstitialCompletionHandler else { return }
        interstitialDelegate = handler(self, nil)
    }

    func interstitial(_ interstitial: CRInterstitial!, didFailToReceiveAdWithError error: Error!) {
        guard let handler = interstitialCompletionHandler else { return }
        let crError = NSError(domain: GADErrorDomain,
                              code: GADErrorCode.noFill.rawValue,
                              userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
        interstitialDelegate = handler(nil, crError)
    }

    func interstitialWillAppear(_ interstitial: CRInterstitial!) {
        interstitialDelegate?.willPresentFullScreenView()
        interstitialDelegate?.reportImpression()
    }

    func interstitialWillDisappear(_ interstitial: CRInterstitial!) {
        interstitialDelegate?.willDismissFullScreenView()
    }

    func interstitialDidDisappear(_ interstitial: CRInterstitial!) {
        interstitialDelegate?.didDismissFullScreenView()
    }

    func interstitialWillLeaveApplication(_ interstitial: CRInterstitial!) {
        interstitialDelegate?.reportClick()
    }

    func interstitialWasClicked(_ interstitial: CRInterstitial!) {
        interstitialDelegate?.reportClick()
    }
}

// MARK: - CRBannerViewDelegate implementation
extension CRCustomEvent: CRBannerViewDelegate {
    func bannerDidReceiveAd(_ bannerView: CRBannerView!) {
        guard let handler = bannerCompletionHandler else { return }
        bannerDelegate = handler(self, nil)
    }

    func banner(_ bannerView: CRBannerView!, didFailToReceiveAdWithError error: Error!) {
        guard let handler = bannerCompletionHandler else { return }
        let crError = NSError(domain: GADErrorDomain,
                              code: GADErrorCode.noFill.rawValue,
                              userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
        bannerDelegate = handler(nil, crError)
    }

    func bannerWillLeaveApplication(_ bannerView: CRBannerView!) {
        bannerDelegate?.reportClick()
    }
}

// MARK: - GADMediationBannerAd implementation
extension CRCustomEvent: GADMediationBannerAd {
    var view: UIView {
        return bannerView ?? UIView()
    }
}
