//
//  CRInterstitialCustomEvent.swift
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

import Foundation
import GoogleMobileAds
import CriteoPublisherSdk

@objc class CRInterstitialCustomEvent: NSObject, CRCOPPAIntegration {
    /// Interstitial ad
    var interstitial: CRInterstitial?
    /// The ad event delegate to forward ad rendering events to the Google Mobile Ads SDK.
    var delegate: GADMediationInterstitialAdEventDelegate?
    /// Completion handler called after ad load
    var completionHandler: GADMediationInterstitialLoadCompletionHandler?

    required override init() {
      super.init()
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
            delegate = completionHandler(nil, error)
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
        self.completionHandler = completionHandler
        self.interstitial?.delegate = self
        self.interstitial?.loadAd()
    }
}

// MARK: - GADMediationInterstitialAd implementation
extension CRInterstitialCustomEvent: GADMediationInterstitialAd {
    func present(from viewController: UIViewController) {
        guard let ad = interstitial, ad.isAdLoaded else { return }
        ad.present(fromRootViewController: viewController)
    }
}

// MARK: - CRInterstitialDelegate implementation
extension CRInterstitialCustomEvent: CRInterstitialDelegate {
    func interstitialDidReceiveAd(_ interstitial: CRInterstitial!) {
        guard let handler = completionHandler else { return }
        delegate = handler(self, nil)
    }

    func interstitial(_ interstitial: CRInterstitial!, didFailToReceiveAdWithError error: Error!) {
        guard let handler = completionHandler else { return }
        let crError = NSError(domain: GADErrorDomain,
                              code: GADErrorCode.noFill.rawValue,
                              userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
        delegate = handler(nil, crError)
    }

    func interstitialWillAppear(_ interstitial: CRInterstitial!) {
        delegate?.willPresentFullScreenView()
        delegate?.reportImpression()
    }

    func interstitialWillDisappear(_ interstitial: CRInterstitial!) {
        delegate?.willDismissFullScreenView()
    }

    func interstitialDidDisappear(_ interstitial: CRInterstitial!) {
        delegate?.didDismissFullScreenView()
    }

    func interstitialWillLeaveApplication(_ interstitial: CRInterstitial!) {
        delegate?.reportClick()
    }

    func interstitialWasClicked(_ interstitial: CRInterstitial!) {
        delegate?.reportClick()
    }
}

