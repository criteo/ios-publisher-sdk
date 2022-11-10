//
//  CRBannerCustomEvent.swift
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

@objc class CRBannerCustomEvent: NSObject, CRCOPPAIntegration {
    /// The Banner ad
    var bannerView: CRBannerView?

    /// The ad event delegate to forward ad rendering events to the Google Mobile Ads SDK.
    var delegate: GADMediationBannerAdEventDelegate?

    /// Completion handler called after ad load
    var completionHandler: GADMediationBannerLoadCompletionHandler?

    required override init() {
        super.init()
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
            delegate = completionHandler(nil, error)
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

        self.completionHandler = completionHandler
        bannerView?.delegate = self
        bannerView?.loadAd()
    }
}

// MARK: - GADMediationBannerAd implementation
extension CRBannerCustomEvent: GADMediationBannerAd {
    var view: UIView {
        return bannerView ?? UIView()
    }
}

// MARK: - CRBannerViewDelegate implementation
extension CRBannerCustomEvent: CRBannerViewDelegate {
    func bannerDidReceiveAd(_ bannerView: CRBannerView!) {
        guard let handler = completionHandler else { return }
        delegate = handler(self, nil)
    }

    func banner(_ bannerView: CRBannerView!, didFailToReceiveAdWithError error: Error!) {
        guard let handler = completionHandler else { return }
        let crError = NSError(domain: GADErrorDomain,
                              code: GADErrorCode.noFill.rawValue,
                              userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
        delegate = handler(nil, crError)
    }

    func bannerWillLeaveApplication(_ bannerView: CRBannerView!) {
        delegate?.reportClick()
    }
}
