//
//  CR_CdbResponseMock.swift
//  CriteoPublisherSdkTests
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


class CR_CdbResponseMock: CR_CdbResponse {


  // MARK: - Overrides

  private var cdbBidsOverride: Array<CR_CdbBid>? = nil

  override var cdbBids: Array<CR_CdbBid> {
    get {
      return cdbBidsOverride ?? super.cdbBids
    }
    set {
      super.cdbBids = newValue
    }
  }
}


// MARK: - MockProtocol

extension CR_CdbResponseMock: MockProtocol {

  func reset() {
    cdbBidsOverride = nil
  }
}
