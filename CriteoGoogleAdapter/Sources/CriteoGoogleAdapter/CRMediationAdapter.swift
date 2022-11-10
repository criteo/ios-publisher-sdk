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
    fileprivate var banner: CRBannerCustomEvent?

    // MARK: - Life Cycle
    required override init() {
        super.init()
    }
}

// MARK: - GADMediationAdapter
extension CRMediationAdapter: GADMediationAdapter {
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
        banner = CRBannerCustomEvent()
        banner?.loadBanner(for: adConfiguration,
                           completionHandler: completionHandler)

    }

    func loadInterstitial(for adConfiguration: GADMediationInterstitialAdConfiguration,
                          completionHandler: @escaping GADMediationInterstitialLoadCompletionHandler) {

    }
}
