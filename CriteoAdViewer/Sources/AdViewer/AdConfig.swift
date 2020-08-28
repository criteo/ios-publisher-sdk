//
//  AdConfig.swift
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

struct AdConfig {
    let publisherId: String
    let adUnit: CRAdUnit
    let adFormat: AdFormat

    init(publisherId: String, adUnitId: String, adFormat: AdFormat) {
        self.publisherId = publisherId
        self.adUnit = AdConfig.buildAdUnit(adFormat: adFormat, adUnitId: adUnitId)
        self.adFormat = adFormat
    }

    private static func buildAdUnit(adFormat: AdFormat, adUnitId: String) -> CRAdUnit {
        switch (adFormat) {
        case .sized(.banner, let size):
            return CRBannerAdUnit(adUnitId: adUnitId, size: size.cgSize())
        case .flexible(.native):
            return CRNativeAdUnit(adUnitId: adUnitId)
        case .flexible(.interstitial):
            return CRInterstitialAdUnit(adUnitId: adUnitId)
        case _:
            fatalError("Unsupported")
        }
    }
}
