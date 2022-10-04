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

  lazy var apiHandlerMock: CR_ApiHandlerMock = {
    let apiHandlerMock = CR_ApiHandlerMock(dependencyProvider: dependencyProvider)
    dependencyProvider.apiHandler = apiHandlerMock
    return apiHandlerMock
  }()

  lazy var bidManagerMock: CR_BidManagerMock = {
    let bidManagerMock = CR_BidManagerMock(dependencyProvider: dependencyProvider)
    dependencyProvider.bidManager = bidManagerMock
    return bidManagerMock
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
    // Try to not mock unneccesasy. Having entire test suite mocking obscures the intent of each test.
    // Try to use the lazy mocked objects as on-demand basis.
  }

  override func tearDown() {

//      [self.loggingMock stopMocking];
//      [self.dependencyProvider.feedbackStorage popMessagesToSend];

    super.tearDown()
  }


  // MARK: - Helper Private Functions

  private func createAdUnit(type: CRAdUnitType = .banner) -> CR_CacheAdUnit {

    let adUnitId = "adUnit_\(UUID().uuidString)"
    return CR_CacheAdUnit(adUnitId: adUnitId, size: CGSize(width: 300, height: 250), adUnitType: type)
  }

  private enum CR_CdbBidType {
    case expired
    case immediate
    case noBid
    case normal
    case silenced
  }

  private func createBid(adUnit: CR_CacheAdUnit, type: CR_CdbBidType = .normal) -> CR_CdbBid {

    var bidBuilder = CR_CdbBidBuilder() // FIXME: for some reason it gets nil unless stored as a separate variable
    bidBuilder = bidBuilder.adUnit(adUnit)

    switch type {
    case .expired: bidBuilder = bidBuilder.expired()
    case .immediate: bidBuilder = bidBuilder.immediate()
    case .noBid: bidBuilder = bidBuilder.noBid()
    case .normal: break
    case .silenced: bidBuilder = bidBuilder.silenced()
    }

    return bidBuilder.build
  }


  // MARK: - Tests for Cache Bidding

  /// Having a cached bid, when fetching a new bid, the expectation is to get the initial cached bid.
  func testGetBidForCachedAdUnits() {

    let adUnit1 = createAdUnit()
    let adUnit2 = createAdUnit()
    let adUnitRewarded = createAdUnit(type: .rewarded)
    let bid1 = createBid(adUnit: adUnit1)
    let bid2 = createBid(adUnit: adUnit2)
    let bidRewarded = createBid(adUnit: adUnitRewarded)

    dependencyProvider.cacheManager.bidCache[adUnit1] = bid1
    dependencyProvider.cacheManager.bidCache[adUnit2] = bid2
    dependencyProvider.cacheManager.bidCache[adUnitRewarded] = bidRewarded

    apiHandlerMock.reset()
    XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
    XCTAssertNil(apiHandlerMock.callCdbAdUnits)
    let bidFetchExpectation1 = expectation(description: "Bid fetch finish expectation")
    let responseHandler1: CR_CdbBidResponseHandler = { (_) -> Void in bidFetchExpectation1.fulfill() }
    let bid1Received = dependencyProvider.bidManager.getBidThenFetch(adUnit1, withContext: contextData, responseHandler: responseHandler1)
    XCTAssertEqual(bid1Received, bid1)
    wait(for: [bidFetchExpectation1], timeout: timeout)
    XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
    XCTAssertEqual(apiHandlerMock.callCdbAdUnits?.first, adUnit1)

    apiHandlerMock.reset()
    XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
    XCTAssertNil(apiHandlerMock.callCdbAdUnits)
    let bidFetchExpectation2 = expectation(description: "Bid fetch finish expectation")
    let responseHandler2: CR_CdbBidResponseHandler = { (_) -> Void in bidFetchExpectation2.fulfill() }
    let bid2Received = dependencyProvider.bidManager.getBidThenFetch(adUnit2, withContext: contextData, responseHandler: responseHandler2)
    XCTAssertEqual(bid2Received, bid2)
    wait(for: [bidFetchExpectation2], timeout: timeout)
    XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
    XCTAssertEqual(apiHandlerMock.callCdbAdUnits?.first, adUnit2)

    apiHandlerMock.reset()
    XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
    XCTAssertNil(apiHandlerMock.callCdbAdUnits)
    let bidFetchExpectation3 = expectation(description: "Bid fetch finish expectation")
    let responseHandler3: CR_CdbBidResponseHandler = { (_) -> Void in bidFetchExpectation3.fulfill() }
    let bidRewardedReceived = dependencyProvider.bidManager.getBidThenFetch(adUnitRewarded, withContext: contextData, responseHandler: responseHandler3)
    XCTAssertEqual(bidRewardedReceived, bidRewarded)
    wait(for: [bidFetchExpectation3], timeout: timeout)
    XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
    XCTAssertEqual(apiHandlerMock.callCdbAdUnits?.first, adUnitRewarded)
  }

  /// Having no cached bid, when fetching a new bid, the expectation is to get an empty bid.
  func testGetBidForUncachedAdUnit() {

    let adUnit = createAdUnit()

    apiHandlerMock.reset()
    XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
    XCTAssertNil(apiHandlerMock.callCdbAdUnits)
    let bidFetchExpectation = expectation(description: "Bid fetch finish expectation")
    let responseHandler: CR_CdbBidResponseHandler = { (_) -> Void in bidFetchExpectation.fulfill() }
    let bid = dependencyProvider.bidManager.getBidThenFetch(adUnit, withContext: contextData, responseHandler: responseHandler)
    wait(for: [bidFetchExpectation], timeout: timeout)
    XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
    XCTAssertEqual(apiHandlerMock.callCdbAdUnits?.first, adUnit)
    do {
      let isEmpty = try XCTUnwrap(bid?.isEmpty())
      XCTAssertTrue(isEmpty)
    } catch {
      XCTFail("Variable bid is nil!")
    }
  }

  /// Having no cached bid, when fetching a new bid, the expectation is to keep the already cached bids.
  func testGetEmptyBid() {

    let adUnit = createAdUnit()

    apiHandlerMock.reset()
    XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
    XCTAssertNil(apiHandlerMock.callCdbAdUnits)
    cacheManagerMock.reset()
    XCTAssertFalse(cacheManagerMock.removeBidWasCalled)
    let bidFetchExpectation = expectation(description: "Bid fetch finish expectation")
    let responseHandler: CR_CdbBidResponseHandler = { (_) -> Void in bidFetchExpectation.fulfill() }
    let bid = dependencyProvider.bidManager.getBidThenFetch(adUnit, withContext: contextData, responseHandler: responseHandler)
    wait(for: [bidFetchExpectation], timeout: timeout)
    XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
    XCTAssertEqual(apiHandlerMock.callCdbAdUnits?.first, adUnit)
    XCTAssertFalse(cacheManagerMock.removeBidWasCalled)
    do {
      let isEmpty = try XCTUnwrap(bid?.isEmpty())
      XCTAssertTrue(isEmpty)
    } catch {
      XCTFail("Variable bid is nil!")
    }
  }

  /// Having a silenced bid manager, having no cached bid, when fetching a new bid, the expectation is to get an empty bid.
  func testGetBidUncachedAdUnitInSilentMode() {

    let adUnit = createAdUnit()
    dependencyProvider.bidManager.cdbTimeToNextCall = TimeInterval.infinity // silence user

    apiHandlerMock.reset()
    XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
    XCTAssertNil(apiHandlerMock.callCdbAdUnits)
    let bidFetchExpectation = expectation(description: "Bid fetch finish expectation")
    let responseHandler: CR_CdbBidResponseHandler = { (_) -> Void in bidFetchExpectation.fulfill() }
    let bid = dependencyProvider.bidManager.getBidThenFetch(adUnit, withContext: contextData, responseHandler: responseHandler)
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

  /// Having a long wait time until next bid fetch, having a cached bid, when fetching a new bid, the expectation is to get the initial cached bid.
  func testGetBidWhenBeforeTimeToNextCall() {

    let adUnit1 = createAdUnit()
    let adUnit2 = createAdUnit()
    let bid1 = createBid(adUnit: adUnit1)
    let bid2 = createBid(adUnit: adUnit2)

    dependencyProvider.bidManager.cdbTimeToNextCall = Date(timeIntervalSinceNow: 360).timeIntervalSinceReferenceDate
    dependencyProvider.cacheManager.bidCache[adUnit1] = bid1
    dependencyProvider.cacheManager.bidCache[adUnit2] = bid2

    apiHandlerMock.reset()
    XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
    XCTAssertNil(apiHandlerMock.callCdbAdUnits)
    let bidFetchExpectation1 = expectation(description: "Bid fetch finish expectation")
    let responseHandler1: CR_CdbBidResponseHandler = { (_) -> Void in bidFetchExpectation1.fulfill() }
    let bid1Received = dependencyProvider.bidManager.getBidThenFetch(adUnit1, withContext: contextData, responseHandler: responseHandler1)
    XCTAssertEqual(bid1Received, bid1)
    wait(for: [bidFetchExpectation1], timeout: timeout)
    XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
    XCTAssertNil(apiHandlerMock.callCdbAdUnits)

    let bidFetchExpectation2 = expectation(description: "Bid fetch finish expectation")
    let responseHandler2: CR_CdbBidResponseHandler = { (_) -> Void in bidFetchExpectation2.fulfill() }
    let bid2Received = dependencyProvider.bidManager.getBidThenFetch(adUnit2, withContext: contextData, responseHandler: responseHandler2)
    wait(for: [bidFetchExpectation2], timeout: timeout)
    XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
    XCTAssertNil(apiHandlerMock.callCdbAdUnits)
    XCTAssertEqual(bid2Received, bid2)
  }

  /// Having a silenced ad unit, having no cached bid, when fetching a new bid, the expectation is to get an empty bid.
  func testGetBidForAdUnitInSilenceMode() {

    let adUnit = createAdUnit()
    let bidSilenced = createBid(adUnit: adUnit, type: .silenced)
    dependencyProvider.cacheManager.bidCache[adUnit] = bidSilenced

    apiHandlerMock.reset()
    XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
    XCTAssertNil(apiHandlerMock.callCdbAdUnits)
    let bidFetchExpectation = expectation(description: "Bid fetch finish expectation")
    let responseHandler: CR_CdbBidResponseHandler = { (_) -> Void in bidFetchExpectation.fulfill() }
    let bid = dependencyProvider.bidManager.getBidThenFetch(adUnit, withContext: contextData, responseHandler: responseHandler)
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

  /// Having an expired silenced ad unit, having a cached bid, when fetching a new bid, the expectation is to get the initial cached bid.
  func testGetBidForBidWithSilencedModeElapsed() {

    let adUnit = createAdUnit()
    let bidExpired = createBid(adUnit: adUnit, type: .expired)
    dependencyProvider.cacheManager.bidCache[adUnit] = bidExpired

    apiHandlerMock.reset()
    XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
    XCTAssertNil(apiHandlerMock.callCdbAdUnits)
    let bidFetchExpectation = expectation(description: "Bid fetch finish expectation")
    let responseHandler: CR_CdbBidResponseHandler = { (_) -> Void in bidFetchExpectation.fulfill() }
    let bid = dependencyProvider.bidManager.getBidThenFetch(adUnit, withContext: contextData, responseHandler: responseHandler)
    wait(for: [bidFetchExpectation], timeout: timeout)
    XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
    XCTAssertEqual(apiHandlerMock.callCdbAdUnits?.first, adUnit)
    do {
      let isEmpty = try XCTUnwrap(bid?.isEmpty())
      XCTAssertTrue(isEmpty)
    } catch {
      XCTFail("Variable bid is nil!")
    }
  }

  /// Having a no-bid cached bid, when fetching a new bid, the expectation is to get the initial empty cached bid.
  func testGetBidWhenNoBid() {

    let adUnit = createAdUnit()
    let bidNoBid = createBid(adUnit: adUnit, type: .noBid)
    dependencyProvider.cacheManager.bidCache[adUnit] = bidNoBid

    apiHandlerMock.reset()
    XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
    XCTAssertNil(apiHandlerMock.callCdbAdUnits)
    let bidFetchExpectation = expectation(description: "Bid fetch finish expectation")
    let responseHandler: CR_CdbBidResponseHandler = { (_) -> Void in bidFetchExpectation.fulfill() }
    let bid = dependencyProvider.bidManager.getBidThenFetch(adUnit, withContext: contextData, responseHandler: responseHandler)
    wait(for: [bidFetchExpectation], timeout: timeout)
    XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
    XCTAssertEqual(apiHandlerMock.callCdbAdUnits?.first, adUnit)
    do {
      let isEmpty = try XCTUnwrap(bid?.isEmpty())
      XCTAssertTrue(isEmpty)
    } catch {
      XCTFail("Variable bid is nil!")
    }
  }

  /// Having an expired cached bid, when fetching a new bid, the expectation is to get the initial empty cached bid.
  func testGetBidWhenBidExpired() {

    let adUnit = createAdUnit()
    let bidExpired = createBid(adUnit: adUnit, type: .expired)
    dependencyProvider.cacheManager.bidCache[adUnit] = bidExpired

    apiHandlerMock.reset()
    XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
    XCTAssertNil(apiHandlerMock.callCdbAdUnits)
    let bidFetchExpectation = expectation(description: "Bid fetch finish expectation")
    let responseHandler: CR_CdbBidResponseHandler = { (_) -> Void in bidFetchExpectation.fulfill() }
    let bid = dependencyProvider.bidManager.getBidThenFetch(adUnit, withContext: contextData, responseHandler: responseHandler)
    wait(for: [bidFetchExpectation], timeout: timeout)
    XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
    XCTAssertEqual(apiHandlerMock.callCdbAdUnits?.first, adUnit)
    do {
      let isEmpty = try XCTUnwrap(bid?.isEmpty())
      XCTAssertTrue(isEmpty)
    } catch {
      XCTFail("Variable bid is nil!")
    }
  }

  /// When initializing the dependency provider the expectation is to not refresh the configuration.
  func testInitDoNotRefreshConfiguration() {
    XCTAssertFalse(configManagerMock.refreshConfigWasCalled)
  }

  /// Having live bidding enabled, when fetching a new bid, a request to CDB should be made.
  func testGetBid_GivenLiveBiddingIsEnabled_ThenFetchLiveBid() {

    let adUnit = createAdUnit()
    dependencyProvider.config.isLiveBiddingEnabled = true

    let loadBidExpectation = expectation(description: "Load bid finish expectation")
    let responseHandler: CR_CdbBidResponseHandler = { (bid) -> Void in
      XCTAssertNil(bid)
      loadBidExpectation.fulfill()
    }
    bidManagerMock.reset()
    XCTAssertFalse(bidManagerMock.fetchLiveBidWasCalled)
    XCTAssertFalse(bidManagerMock.getBidThenFetchWasCalled)
    dependencyProvider.bidManager.loadCdbBid(for: adUnit, withContext: contextData, responseHandler: responseHandler)
    XCTAssertTrue(bidManagerMock.fetchLiveBidWasCalled)
    XCTAssertFalse(bidManagerMock.getBidThenFetchWasCalled)
    wait(for: [loadBidExpectation], timeout: timeout)
  }

  /// Having live bidding disabled, when fetching a new bid, a request to CDB should not be made.
  func testGetBid_GivenLiveBiddingIsDisabled_ThenGetBidThenFetch() {

    let adUnit = createAdUnit()
    dependencyProvider.config.isLiveBiddingEnabled = false

    let loadBidExpectation = expectation(description: "Load bid finish expectation")
    let responseHandler: CR_CdbBidResponseHandler = { (bid) -> Void in
      XCTAssertNil(bid)
      loadBidExpectation.fulfill()
    }
    bidManagerMock.reset()
    XCTAssertFalse(bidManagerMock.fetchLiveBidWasCalled)
    XCTAssertFalse(bidManagerMock.getBidThenFetchWasCalled)
    dependencyProvider.bidManager.loadCdbBid(for: adUnit, withContext: contextData, responseHandler: responseHandler)
    XCTAssertFalse(bidManagerMock.fetchLiveBidWasCalled)
    XCTAssertTrue(bidManagerMock.getBidThenFetchWasCalled)
    wait(for: [loadBidExpectation], timeout: timeout)
  }


  // MARK: - Helpers for Live Bidding

  /// Helper function used for live bidding tests.
  /// - parameter adUnit: Ad unit to be used for fetch request.
  /// - parameter callCdbShouldBeCalled: Adds an assert with the expectation of a request to CDB was or wasn't made.
  /// - parameter bidCached: Adds an assert with the expectation of a bid to be cached. Also adds an assert with the expectation of the feedback manager on bid cached call.
  /// - parameter bidConsumed: Adds an assert with the expectation of the feedback manager on bid consumed call.
  /// - parameter bidResponded: Adds an assert with the expectation of the returned bid to be equal. If nil, the responded bid should also be nil or empty.
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

    let adUnit = createAdUnit()
    let bid = createBid(adUnit: adUnit)
    let bidImmediate = createBid(adUnit: adUnit, type: .immediate)

    cacheManagerMock.bidCache[adUnit] = bid
    cdbResponseMock.cdbBids = [bidImmediate]
    synchronousThreadManager.isTimeout = false

    let fetchLiveBidExpectation = fetchLiveBid(adUnit: adUnit, callCdbShouldBeCalled: true, bidCached: nil, bidConsumed: bidImmediate, bidResponded: bidImmediate)
    wait(for: [fetchLiveBidExpectation], timeout: timeout)

    do {
      let cachedBid = try XCTUnwrap(dependencyProvider.cacheManager.bidCache[adUnit] as? CR_CdbBid)
      XCTAssertNotEqual(cachedBid, bidImmediate)
    } catch {
      XCTFail("Failed to retrieve cached bid!")
    }
  }

  /// Having time budget exceeded, when fetching a live bid, the expectation is to get a new bid and cache it.
  func testLiveBid_GivenResponseAfterTimeBudget_ThenBidFromCacheGiven() {

    let adUnit = createAdUnit()
    let bidImmediate = createBid(adUnit: adUnit, type: .immediate)
    cdbResponseMock.cdbBids = [bidImmediate]
    synchronousThreadManager.isTimeout = true

    let fetchLiveBidExpectation = fetchLiveBid(adUnit: adUnit, callCdbShouldBeCalled: true, bidCached: bidImmediate, bidConsumed: bidImmediate, bidResponded: bidImmediate)
    wait(for: [fetchLiveBidExpectation], timeout: timeout)
  }

  /// Having an existing cached bid, and having no bid returned from fetching, the expectation is to use the initial cached bid.
  func testLiveBid_GivenResponseError_ThenBidFromCacheGiven() {

    let adUnit = createAdUnit()
    let bid = createBid(adUnit: adUnit)

    XCTAssertNil(apiHandlerMock.callCdbCdbResponse)
    cacheManagerMock.bidCache[adUnit] = bid
    let fetchLiveBidExpectation = fetchLiveBid(adUnit: adUnit, callCdbShouldBeCalled: true, bidCached: nil, bidConsumed: bid, bidResponded: bid)
    wait(for: [fetchLiveBidExpectation], timeout: timeout)
  }

  func testLiveBid_GivenResponseAfterTimeBudgetAndNoBidInCache_ThenNoBidGiven() {

    synchronousThreadManager.isTimeout = true
  }
}
