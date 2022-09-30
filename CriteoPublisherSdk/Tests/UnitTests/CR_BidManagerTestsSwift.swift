//
//  CR_BidManagerTestsSwift.swift
//  CriteoPublisherSdk
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
import CriteoPublisherSdk
import XCTest


class CR_BidManagerTestsSwift: XCTestCase {


  // MARK: - Variables

  lazy var adUnit1: CR_CacheAdUnit = { return CR_CacheAdUnit(adUnitId: "adUnit1", width: 300, height: 250) }()
  lazy var adUnit2: CR_CacheAdUnit = { return CR_CacheAdUnit(adUnitId: "adUnit2", width: 200, height: 100) }()
  lazy var adUnitEmptyBid: CR_CacheAdUnit = { return CR_CacheAdUnit(adUnitId: "adUnitEmptyBid", width: 300, height: 250) }()
  lazy var adUnitRewarded: CR_CacheAdUnit = { return CR_CacheAdUnit(adUnitId: "adUnitRewarded", size: CGSize(width: 200, height: 100), adUnitType: .rewarded) }()
  lazy var adUnitUncached: CR_CacheAdUnit = { return CR_CacheAdUnit(adUnitId: "adUnitUncached", width: 200, height: 100) }()

  lazy var apiHandlerMock: CR_ApiHandlerMock = {
    let apiHandlerMock = CR_ApiHandlerMock(dependencyProvider: dependencyProvider)
    dependencyProvider.apiHandler = apiHandlerMock
    return apiHandlerMock
  }()

  lazy var bid1: CR_CdbBid = {
    let bidBuilder = CR_CdbBidBuilder() // FIXME: for some reason it gets nil unless stored as a separate variable
    return bidBuilder.adUnit(adUnit1).build
  }()

  lazy var bid2: CR_CdbBid = {
    let bidBuilder = CR_CdbBidBuilder() // FIXME: for some reason it gets nil unless stored as a separate variable
    return bidBuilder.adUnit(adUnit2).cpm("0.5").displayUrl("bid2.displayUrl").build
  }()

  lazy var bidManagerMock: CR_BidManagerMock = {
    let bidManagerMock = CR_BidManagerMock(dependencyProvider: dependencyProvider)
    dependencyProvider.bidManager = bidManagerMock
    return bidManagerMock
  }()

  lazy var bidImmediate1: CR_CdbBid = {
    let bidBuilder = CR_CdbBidBuilder() // FIXME: for some reason it gets nil unless stored as a separate variable
    return bidBuilder.adUnit(adUnit1).immediate().build
  }()

  lazy var bidRewarded: CR_CdbBid = {
    let bidBuilder = CR_CdbBidBuilder() // FIXME: for some reason it gets nil unless stored as a separate variable
    return bidBuilder.adUnit(adUnitRewarded).build
  }()

  lazy var cacheManagerMock: CR_CacheManagerMock = {
    let cacheManagerMock = CR_CacheManagerMock()
    dependencyProvider.cacheManager = cacheManagerMock
    return cacheManagerMock
  }()

  lazy var cdbResponseMock: CR_CdbResponseMock = {
    let cdbResponseMock = CR_CdbResponseMock()
    apiHandlerMock.callCdbCdbResponse = cdbResponseMock
    return cdbResponseMock
  }()

  lazy var configManagerMock: CR_ConfigManagerMock = {
    let configManagerMock = CR_ConfigManagerMock(dependencyProvider: dependencyProvider)
    dependencyProvider.configManager = configManagerMock
    return configManagerMock
  }()

  lazy var contextData: CRContextData = { return CRContextData() }()

  lazy var dependencyProvider: CR_DependencyProvider = { return CR_DependencyProvider.testing() }()

  lazy var feedbackDelegateMock: CR_FeedbackDelegateMock = {
    let feedbackDelegateMock = CR_FeedbackDelegateMock()
    dependencyProvider.feedbackDelegate = feedbackDelegateMock
    return feedbackDelegateMock
  }()

  lazy var synchronousThreadManager: CR_SynchronousThreadManager = {
    let synchronousThreadManager = CR_SynchronousThreadManager()
    dependencyProvider.threadManager = synchronousThreadManager
    return synchronousThreadManager
  }()

  lazy var timeout: TimeInterval = 10


  // MARK: - Life Cycle

  override func setUp() {
    super.setUp()

//    dependencyProvider.apiHandler = apiHandlerMock
//    dependencyProvider.cacheManager = cacheManagerMock
//    dependencyProvider.configManager = configManagerMock
//    dependencyProvider.threadManager = threadManager

//    cacheManagerMock.bidCache[adUnit1] = bid1
//    cacheManagerMock.bidCache[adUnit2] = bid2
    // cache [adUnitForEmptyBid]
//    cacheManagerMock.bidCache[adUnitRewarded] = bidRewarded



    // TODO: Do not mock unneccesarily essay here
    // TODO: because it obscures the intent of the content that needs to be tested
  }

  override func tearDown() {

//      [self.loggingMock stopMocking];
//      [self.dependencyProvider.feedbackStorage popMessagesToSend];

    super.tearDown()
  }


  // MARK: - Tests for Cache Bidding

  func testGetBidForCachedAdUnits() {

    dependencyProvider.cacheManager.bidCache[adUnit1] = bid1
    dependencyProvider.cacheManager.bidCache[adUnit2] = bid2
    dependencyProvider.cacheManager.bidCache[adUnitRewarded] = bidRewarded

    apiHandlerMock.reset()
    XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
    XCTAssertNil(apiHandlerMock.callCdbAdUnits)
    let bidFetchExpectation1 = expectation(description: "Bid fetch finish expectation")
    let responseHandler1: CR_CdbBidResponseHandler = { (_) -> Void in bidFetchExpectation1.fulfill() }
    let bid1 = dependencyProvider.bidManager.getBidThenFetch(adUnit1, withContext: contextData, responseHandler: responseHandler1)
    XCTAssertEqual(bid1, self.bid1)
    wait(for: [bidFetchExpectation1], timeout: timeout)
    XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
    XCTAssertEqual(apiHandlerMock.callCdbAdUnits?.first, adUnit1)

    apiHandlerMock.reset()
    XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
    XCTAssertNil(apiHandlerMock.callCdbAdUnits)
    let bidFetchExpectation2 = expectation(description: "Bid fetch finish expectation")
    let responseHandler2: CR_CdbBidResponseHandler = { (_) -> Void in bidFetchExpectation2.fulfill() }
    let bid2 = dependencyProvider.bidManager.getBidThenFetch(adUnit2, withContext: contextData, responseHandler: responseHandler2)
    XCTAssertEqual(bid2, self.bid2)
    wait(for: [bidFetchExpectation2], timeout: timeout)
    XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
    XCTAssertEqual(apiHandlerMock.callCdbAdUnits?.first, adUnit2)

    apiHandlerMock.reset()
    XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
    XCTAssertNil(apiHandlerMock.callCdbAdUnits)
    let bidFetchExpectation3 = expectation(description: "Bid fetch finish expectation")
    let responseHandler3: CR_CdbBidResponseHandler = { (_) -> Void in bidFetchExpectation3.fulfill() }
    let bidRewarded = dependencyProvider.bidManager.getBidThenFetch(adUnitRewarded, withContext: contextData, responseHandler: responseHandler3)
    XCTAssertEqual(bidRewarded, self.bidRewarded)
    wait(for: [bidFetchExpectation3], timeout: timeout)
    XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
    XCTAssertEqual(apiHandlerMock.callCdbAdUnits?.first, adUnitRewarded)
  }

  func testGetBidForUncachedAdUnit() {

    apiHandlerMock.reset()
    XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
    XCTAssertNil(apiHandlerMock.callCdbAdUnits)
    let bidFetchExpectation = expectation(description: "Bid fetch finish expectation")
    let responseHandler: CR_CdbBidResponseHandler = { (_) -> Void in bidFetchExpectation.fulfill() }
    let bid = dependencyProvider.bidManager.getBidThenFetch(adUnitUncached, withContext: contextData, responseHandler: responseHandler)
    wait(for: [bidFetchExpectation], timeout: timeout)
    XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
    XCTAssertEqual(apiHandlerMock.callCdbAdUnits?.first, adUnitUncached)
    do {
      let isEmpty = try XCTUnwrap(bid?.isEmpty())
      XCTAssertTrue(isEmpty)
    } catch {
      XCTFail("Variable bid is nil!")
    }
  }

  func testGetEmptyBid() {

    apiHandlerMock.reset()
    XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
    XCTAssertNil(apiHandlerMock.callCdbAdUnits)
    cacheManagerMock.reset()
    XCTAssertFalse(cacheManagerMock.removeBidWasCalled)
    let bidFetchExpectation = expectation(description: "Bid fetch finish expectation")
    let responseHandler: CR_CdbBidResponseHandler = { (_) -> Void in bidFetchExpectation.fulfill() }
    let bid = dependencyProvider.bidManager.getBidThenFetch(adUnitEmptyBid, withContext: contextData, responseHandler: responseHandler)
    wait(for: [bidFetchExpectation], timeout: timeout)
    XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
    XCTAssertEqual(apiHandlerMock.callCdbAdUnits?.first, adUnitEmptyBid)
    XCTAssertFalse(cacheManagerMock.removeBidWasCalled)
    do {
      let isEmpty = try XCTUnwrap(bid?.isEmpty())
      XCTAssertTrue(isEmpty)
    } catch {
      XCTFail("Variable bid is nil!")
    }
  }

  func testGetBidUncachedAdUnitInSilentMode() {

    dependencyProvider.bidManager.cdbTimeToNextCall = TimeInterval.infinity // silence user

    apiHandlerMock.reset()
    XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
    XCTAssertNil(apiHandlerMock.callCdbAdUnits)
    let bidFetchExpectation = expectation(description: "Bid fetch finish expectation")
    let responseHandler: CR_CdbBidResponseHandler = { (_) -> Void in bidFetchExpectation.fulfill() }
    let bid = dependencyProvider.bidManager.getBidThenFetch(adUnitUncached, withContext: contextData, responseHandler: responseHandler)
    wait(for: [bidFetchExpectation], timeout: timeout)
    XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
    XCTAssertNil(apiHandlerMock.callCdbAdUnits)
    do {
      let isEmpty = try XCTUnwrap(bid?.isEmpty())
      XCTAssertTrue(isEmpty)
    } catch {
      XCTFail("Variable bid is nil!")
    }
  }

  func testGetBidWhenBeforeTimeToNextCall() {

    dependencyProvider.bidManager.cdbTimeToNextCall = Date(timeIntervalSinceNow: 360).timeIntervalSinceReferenceDate
    dependencyProvider.cacheManager.bidCache[adUnit1] = bid1
    dependencyProvider.cacheManager.bidCache[adUnit2] = bid2

    apiHandlerMock.reset()
    XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
    XCTAssertNil(apiHandlerMock.callCdbAdUnits)
    let bidFetchExpectation1 = expectation(description: "Bid fetch finish expectation")
    let responseHandler1: CR_CdbBidResponseHandler = { (_) -> Void in bidFetchExpectation1.fulfill() }
    let bid1 = dependencyProvider.bidManager.getBidThenFetch(adUnit1, withContext: contextData, responseHandler: responseHandler1)
    XCTAssertEqual(bid1, self.bid1)
    wait(for: [bidFetchExpectation1], timeout: timeout)
    XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
    XCTAssertNil(apiHandlerMock.callCdbAdUnits)

    let bidFetchExpectation2 = expectation(description: "Bid fetch finish expectation")
    let responseHandler2: CR_CdbBidResponseHandler = { (_) -> Void in bidFetchExpectation2.fulfill() }
    let bid2 = dependencyProvider.bidManager.getBidThenFetch(adUnit2, withContext: contextData, responseHandler: responseHandler2)
    wait(for: [bidFetchExpectation2], timeout: timeout)
    XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
    XCTAssertNil(apiHandlerMock.callCdbAdUnits)
    XCTAssertEqual(bid2, self.bid2)
  }

  func testGetBidForAdUnitInSilenceMode() {

    let bidBuilder = CR_CdbBidBuilder() // FIXME: for some reason it gets nil unless stored as a separate variable
    let bid1 = bidBuilder.adUnit(adUnit1).silenced().build
    dependencyProvider.cacheManager.bidCache[adUnit1] = bid1

    apiHandlerMock.reset()
    XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
    XCTAssertNil(apiHandlerMock.callCdbAdUnits)
    let bidFetchExpectation = expectation(description: "Bid fetch finish expectation")
    let responseHandler: CR_CdbBidResponseHandler = { (_) -> Void in bidFetchExpectation.fulfill() }
    let bid = dependencyProvider.bidManager.getBidThenFetch(adUnit1, withContext: contextData, responseHandler: responseHandler)
    wait(for: [bidFetchExpectation], timeout: timeout)
    XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
    XCTAssertNil(apiHandlerMock.callCdbAdUnits)
    do {
      let isEmpty = try XCTUnwrap(bid?.isEmpty())
      XCTAssertTrue(isEmpty)
    } catch {
      XCTFail("Variable bid is nil!")
    }
  }

  func testGetBidForBidWithSilencedModeElapsed() {

    let bidBuilder = CR_CdbBidBuilder() // FIXME: for some reason it gets nil unless stored as a separate variable
    let bid1 = bidBuilder.adUnit(adUnit1).expired().build
    dependencyProvider.cacheManager.bidCache[adUnit1] = bid1

    apiHandlerMock.reset()
    XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
    XCTAssertNil(apiHandlerMock.callCdbAdUnits)
    let bidFetchExpectation = expectation(description: "Bid fetch finish expectation")
    let responseHandler: CR_CdbBidResponseHandler = { (_) -> Void in bidFetchExpectation.fulfill() }
    let bid = dependencyProvider.bidManager.getBidThenFetch(adUnit1, withContext: contextData, responseHandler: responseHandler)
    wait(for: [bidFetchExpectation], timeout: timeout)
    XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
    XCTAssertEqual(apiHandlerMock.callCdbAdUnits?.first, adUnit1)
    do {
      let isEmpty = try XCTUnwrap(bid?.isEmpty())
      XCTAssertTrue(isEmpty)
    } catch {
      XCTFail("Variable bid is nil!")
    }
  }

  func testGetBidWhenNoBid() {

    let bidBuilder = CR_CdbBidBuilder() // FIXME: for some reason it gets nil unless stored as a separate variable
    let bid1 = bidBuilder.adUnit(adUnit1).noBid().build
    dependencyProvider.cacheManager.bidCache[adUnit1] = bid1

    apiHandlerMock.reset()
    XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
    XCTAssertNil(apiHandlerMock.callCdbAdUnits)
    let bidFetchExpectation = expectation(description: "Bid fetch finish expectation")
    let responseHandler: CR_CdbBidResponseHandler = { (_) -> Void in bidFetchExpectation.fulfill() }
    let bid = dependencyProvider.bidManager.getBidThenFetch(adUnit1, withContext: contextData, responseHandler: responseHandler)
    wait(for: [bidFetchExpectation], timeout: timeout)
    XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
    XCTAssertEqual(apiHandlerMock.callCdbAdUnits?.first, adUnit1)
    do {
      let isEmpty = try XCTUnwrap(bid?.isEmpty())
      XCTAssertTrue(isEmpty)
    } catch {
      XCTFail("Variable bid is nil!")
    }
  }

  func testGetBidWhenBidExpired() {

    let bidBuilder = CR_CdbBidBuilder() // FIXME: for some reason it gets nil unless stored as a separate variable
    let bid1 = bidBuilder.adUnit(adUnit1).expired().build
    dependencyProvider.cacheManager.bidCache[adUnit1] = bid1

    apiHandlerMock.reset()
    XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
    XCTAssertNil(apiHandlerMock.callCdbAdUnits)
    let bidFetchExpectation = expectation(description: "Bid fetch finish expectation")
    let responseHandler: CR_CdbBidResponseHandler = { (_) -> Void in bidFetchExpectation.fulfill() }
    let bid = dependencyProvider.bidManager.getBidThenFetch(adUnit1, withContext: contextData, responseHandler: responseHandler)
    wait(for: [bidFetchExpectation], timeout: timeout)
    XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
    XCTAssertEqual(apiHandlerMock.callCdbAdUnits?.first, adUnit1)
    do {
      let isEmpty = try XCTUnwrap(bid?.isEmpty())
      XCTAssertTrue(isEmpty)
    } catch {
      XCTFail("Variable bid is nil!")
    }
  }

  func testInitDoNotRefreshConfiguration() {
    XCTAssertFalse(configManagerMock.refreshConfigWasCalled)
  }

  func testGetBid_GivenLiveBiddingIsEnabled_ThenFetchLiveBid() {

    dependencyProvider.config.isLiveBiddingEnabled = true

    let loadBidExpectation = expectation(description: "Load bid finish expectation")
    let responseHandler: CR_CdbBidResponseHandler = { (bid) -> Void in
      XCTAssertNil(bid)
      loadBidExpectation.fulfill()
    }
    bidManagerMock.reset()
    XCTAssertFalse(bidManagerMock.fetchLiveBidWasCalled)
    XCTAssertFalse(bidManagerMock.getBidThenFetchWasCalled)
    dependencyProvider.bidManager.loadCdbBid(for: adUnit1, withContext: contextData, responseHandler: responseHandler)
    XCTAssertTrue(bidManagerMock.fetchLiveBidWasCalled)
    XCTAssertFalse(bidManagerMock.getBidThenFetchWasCalled)
    wait(for: [loadBidExpectation], timeout: timeout)
  }

  func testGetBid_GivenLiveBiddingIsDisabled_ThenGetBidThenFetch() {

    dependencyProvider.config.isLiveBiddingEnabled = false

    let loadBidExpectation = expectation(description: "Load bid finish expectation")
    let responseHandler: CR_CdbBidResponseHandler = { (bid) -> Void in
      XCTAssertNil(bid)
      loadBidExpectation.fulfill()
    }
    bidManagerMock.reset()
    XCTAssertFalse(bidManagerMock.fetchLiveBidWasCalled)
    XCTAssertFalse(bidManagerMock.getBidThenFetchWasCalled)
    dependencyProvider.bidManager.loadCdbBid(for: adUnit1, withContext: contextData, responseHandler: responseHandler)
    XCTAssertFalse(bidManagerMock.fetchLiveBidWasCalled)
    XCTAssertTrue(bidManagerMock.getBidThenFetchWasCalled)
    wait(for: [loadBidExpectation], timeout: timeout)
  }


  // MARK: - Helpers for Live Bidding

  //  func expectBidConsumed(bid) {
  //
  //  }

  //  func expectBidCached(bid) {
  //
  //  }

  private func fetchLiveBid(adUnit: CR_CacheAdUnit, callCdbShouldBeCalled: Bool, bidCached: CR_CdbBid?, bidConsumed: CR_CdbBid?, bidResponded: CR_CdbBid?) -> XCTestExpectation {

    let cacheManagerMockSetBidShouldBeCalled = bidCached != nil

    let _ = feedbackDelegateMock
    let feedbackDelegateMockOnBidCachedShouldBeCalled = bidCached != nil
    let feedbackDelegateMockOnBidConsumedShouldBeCalled = bidConsumed != nil

    let fetchLiveBidExpectation = expectation(description: "Fetch live bid finish expectation")
    dependencyProvider.bidManager.fetchLiveBid(for: adUnit, withContext: contextData) { [weak self] bid in

      fetchLiveBidExpectation.fulfill()

      guard let selfUnwrapped = self else {
        XCTFail("Self was nil inside \(#function)")
        return
      }

      if let bidResponded = bidResponded {
        XCTAssertEqual(bid, bidResponded)
      } else {
        XCTAssertTrue(bid?.isEmpty() ?? true) // By having "?? true" basically means the bid is nil
      }

      if callCdbShouldBeCalled {
        XCTAssertTrue(selfUnwrapped.apiHandlerMock.callCdbWasCalled)
        XCTAssertEqual(selfUnwrapped.apiHandlerMock.callCdbAdUnits, [adUnit])
      } else {
        XCTAssertFalse(selfUnwrapped.apiHandlerMock.callCdbWasCalled)
      }

      if cacheManagerMockSetBidShouldBeCalled {
        XCTAssertTrue(selfUnwrapped.cacheManagerMock.setBidWasCalled)
      } else {
        XCTAssertFalse(selfUnwrapped.cacheManagerMock.setBidWasCalled)
      }

      if feedbackDelegateMockOnBidCachedShouldBeCalled {
        XCTAssertTrue(selfUnwrapped.feedbackDelegateMock.onBidCachedWasCalled)
      } else {
        XCTAssertFalse(selfUnwrapped.feedbackDelegateMock.onBidCachedWasCalled)
      }

      if feedbackDelegateMockOnBidConsumedShouldBeCalled {
        XCTAssertTrue(selfUnwrapped.feedbackDelegateMock.onBidConsumedWasCalled)
      } else {
        XCTAssertFalse(selfUnwrapped.feedbackDelegateMock.onBidConsumedWasCalled)
      }
    }

    return fetchLiveBidExpectation
  }


  // MARK: - Tests for Live Bidding

  /// Having an existing cached bid, when fetching a live bid, the expectation is to get a different bid than the initial cached bid.
  func testLiveBid_GivenResponseBeforeTimeBudget_ThenBidFromResponseGiven() {

    cacheManagerMock.bidCache[adUnit1] = bid1
    cdbResponseMock.cdbBids = [bidImmediate1]
    synchronousThreadManager.isTimeout = false

    let fetchLiveBidExpectation = fetchLiveBid(adUnit: adUnit1, callCdbShouldBeCalled: true, bidCached: nil, bidConsumed: bidImmediate1, bidResponded: bidImmediate1)
    wait(for: [fetchLiveBidExpectation], timeout: timeout)

    do {
      let cachedBid = try XCTUnwrap(dependencyProvider.cacheManager.bidCache[adUnit1] as? CR_CdbBid)
      XCTAssertNotEqual(cachedBid, bidImmediate1)
    } catch {
      XCTFail("Failed to retrieve cached bid!")
    }
  }
}
