//
//  CR_BidManagerMock.swift
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


class CR_BidManagerMock: CR_BidManager {


  // MARK: - Life Cycle

  convenience init(dependencyProvider: CR_DependencyProvider) {
    self.init(apiHandler: dependencyProvider.apiHandler, cacheManager: dependencyProvider.cacheManager, config: dependencyProvider.config, deviceInfo: dependencyProvider.deviceInfo, consent: dependencyProvider.consent, networkManager: dependencyProvider.networkManager, headerBidding: dependencyProvider.headerBidding, feedbackDelegate: dependencyProvider.feedbackDelegate, threadManager: dependencyProvider.threadManager, remoteLogHandler: dependencyProvider.remoteLogHandler)
  }


  // MARK: - Overrides

  var fetchLiveBidWasCalled = false

  override func fetchLiveBid(for adUnit: CR_CacheAdUnit!, withContext contextData: CRContextData!, responseHandler: CR_CdbBidResponseHandler!) {
    fetchLiveBidWasCalled = true
    super.fetchLiveBid(for: adUnit, withContext: contextData, responseHandler: responseHandler)
  }

  var getBidThenFetchWasCalled = false

  override func getBidThenFetch(_ slot: CR_CacheAdUnit!, withContext contextData: CRContextData!, responseHandler: CR_CdbBidResponseHandler!) -> CR_CdbBid! {
    getBidThenFetchWasCalled = true
    return super.getBidThenFetch(slot, withContext: contextData, responseHandler: responseHandler)
  }
}


// MARK: - MockProtocol

extension CR_BidManagerMock: MockProtocol {

  func reset() {
    fetchLiveBidWasCalled = false
    getBidThenFetchWasCalled = false
  }
}
