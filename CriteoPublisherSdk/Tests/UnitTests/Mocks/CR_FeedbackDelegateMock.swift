//
//  CR_FeedbackDelegateMock.swift
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


class CR_FeedbackDelegateMock {

  var onCdbCallStartedWasCalled = false
  var onCdbCallWasCalled = false
  var onCdbCallFailureWasCalled = false
  var onBidCachedWasCalled = false
  var onBidCachedWasCalledWithBid: CR_CdbBid?
  var onBidConsumedWasCalled = false
  var onBidConsumedWasCalledWithBid: CR_CdbBid?
  var sendFeedbackBatchWasCalled = false
}


// MARK: - CR_FeedbackDelegate

extension CR_FeedbackDelegateMock: CR_FeedbackDelegate {

  func onCdbCallStarted(_ request: CR_CdbRequest!) {
    onCdbCallStartedWasCalled = true
  }

  func onCdbCall(_ response: CR_CdbResponse!, from request: CR_CdbRequest!) {
    onCdbCallWasCalled = true
  }

  func onCdbCallFailure(_ failure: Error!, from request: CR_CdbRequest!) {
    onCdbCallFailureWasCalled = true
  }

  func onBidCached(_ bid: CR_CdbBid!) {
    onBidCachedWasCalled = true
    onBidCachedWasCalledWithBid = bid
  }

  func onBidConsumed(_ consumedBid: CR_CdbBid!) {
    onBidConsumedWasCalled = true
    onBidConsumedWasCalledWithBid = consumedBid
  }

  func sendFeedbackBatch() {
    sendFeedbackBatchWasCalled = true
  }
}


// MARK: - MockProtocol

extension CR_FeedbackDelegateMock: MockProtocol {

  func reset() {

    onCdbCallStartedWasCalled = false
    onCdbCallWasCalled = false
    onCdbCallFailureWasCalled = false
    onBidCachedWasCalled = false
    onBidCachedWasCalledWithBid = nil
    onBidConsumedWasCalled = false
    onBidConsumedWasCalledWithBid = nil
    sendFeedbackBatchWasCalled = false
  }
}
