//
//  SKAdNetworkInfo.swift
//  CriteoPublisherSdk
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

import Foundation

struct SKAdNetworkInfo {
  let adNetworkIds: [String]
  let hasCriteoId: Bool

  init(bundle: Bundle = Bundle.main) {
    adNetworkIds = SKAdNetworkInfo.getAdNetworkIds(from: bundle)
    hasCriteoId = adNetworkIds.contains(CRSKAdNetworkInfo.CriteoId)
  }
}

extension SKAdNetworkInfo {
  struct Keys {
    static let items = "SKAdNetworkItems"
    static let identifier = "SKAdNetworkIdentifier"
  }

  static func getAdNetworkIds(from bundle: Bundle) -> [String] {
    (bundle.object(forInfoDictionaryKey: Keys.items) as? [[String: String]])?
      .compactMap { item in item[Keys.identifier] } ?? []
  }
}

let skanInfo = SKAdNetworkInfo()

@objc extension CRSKAdNetworkInfo {
  public static let CriteoId = "hs6bdukanm.skadnetwork"

  public class func hasCriteoId() -> Bool {
    skanInfo.hasCriteoId
  }

  public class func skAdNetworkIds() -> [String] {
    skanInfo.adNetworkIds
  }
}
