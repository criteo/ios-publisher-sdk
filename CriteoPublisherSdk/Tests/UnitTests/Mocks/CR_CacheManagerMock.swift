//
//  CR_CacheManagerMock.swift
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


class CR_CacheManagerMock: CR_CacheManager {


  // MARK: - Overrides

  var removeBidWasCalled = false

  override func removeBid(for adUnit: CR_CacheAdUnit!) {
    removeBidWasCalled = true
    super.removeBid(for: adUnit)
  }

  var setBidWasCalled = false
  var setBidWasCalledWithBid: CR_CdbBid?

  override func setBid(_ bid: CR_CdbBid!) -> CR_CacheAdUnit! {
    setBidWasCalled = true
    setBidWasCalledWithBid = bid
    return super.setBid(bid)
  }
}


// MARK: - MockProtocol

extension CR_CacheManagerMock: MockProtocol {

  func reset() {
    removeBidWasCalled = false
    setBidWasCalled = false
    setBidWasCalledWithBid = nil
  }
}
