//
//  CR_HeaderBiddingMock.swift
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

class CR_HeaderBiddingMock: CR_HeaderBidding {

  // MARK: - Life Cycle

  convenience init(dependencyProvider: CR_DependencyProvider) {
    self.init(
      device: dependencyProvider.deviceInfo,
      displaySizeInjector: dependencyProvider.displaySizeInjector,
      integrationRegistry: dependencyProvider.integrationRegistry)
  }

  // MARK: - Overrides

  var enrichRequestWasCalled = false
  var enrichRequestWasCalledWithRequest: Any?
  var enrichRequestWasCalledWithAdUnit: CR_CacheAdUnit?

  override func enrichRequest(_ request: Any, with bid: CR_CdbBid, adUnit: CR_CacheAdUnit) {
    enrichRequestWasCalled = true
    enrichRequestWasCalledWithRequest = request
    enrichRequestWasCalledWithAdUnit = adUnit
  }
}

// MARK: - MockProtocol

extension CR_HeaderBiddingMock: MockProtocol {

  func reset() {
    enrichRequestWasCalled = false
    enrichRequestWasCalledWithRequest = nil
    enrichRequestWasCalledWithAdUnit = nil
  }
}
