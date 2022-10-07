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

  lazy var logHandlerMock: CR_LogHandlerMock = {
    let logHandlerMock = CR_LogHandlerMock()
    let logging = CR_Logging(logHandler: logHandlerMock)
    dependencyProvider.logging = logging
    return logHandlerMock
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
    dependencyProvider.feedbackStorage.popMessagesToSend()

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
    case silenced
  }

  private func createBid(adUnit: CR_CacheAdUnit, types: Array<CR_CdbBidType> = []) -> CR_CdbBid {

    var bidBuilder = CR_CdbBidBuilder() // FIXME: for some reason it gets nil unless stored as a separate variable
    bidBuilder = bidBuilder.adUnit(adUnit)

    for type in types {
      switch type {
      case .expired: bidBuilder = bidBuilder.expired()
      case .immediate: bidBuilder = bidBuilder.immediate()
      case .noBid: bidBuilder = bidBuilder.noBid()
      case .silenced: bidBuilder = bidBuilder.silenced()
      }
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
    let bidFetchExpectation = expectation(description: "Bid fetch finish expectation")
    let responseHandler: CR_CdbBidResponseHandler = { (_) -> Void in bidFetchExpectation.fulfill() }
    let bidReceived = dependencyProvider.bidManager.getBidThenFetch(adUnit, withContext: contextData, responseHandler: responseHandler)
    wait(for: [bidFetchExpectation], timeout: timeout)
    XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
    XCTAssertEqual(apiHandlerMock.callCdbAdUnits?.first, adUnit)
    do {
      let isEmpty = try XCTUnwrap(bidReceived?.isEmpty())
      XCTAssertTrue(isEmpty)
    } catch {
      XCTFail("Variable bid is nil!")
    }
  }

  /// Having no cached bid, when fetching a new bid, the expectation is to keep the already cached bids.
  func testGetEmptyBid() {

    let adUnit = createAdUnit()

    apiHandlerMock.reset()
    cacheManagerMock.reset()
    XCTAssertFalse(cacheManagerMock.removeBidWasCalled)
    let bidFetchExpectation = expectation(description: "Bid fetch finish expectation")
    let responseHandler: CR_CdbBidResponseHandler = { (_) -> Void in bidFetchExpectation.fulfill() }
    let bidReceived = dependencyProvider.bidManager.getBidThenFetch(adUnit, withContext: contextData, responseHandler: responseHandler)
    wait(for: [bidFetchExpectation], timeout: timeout)
    XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
    XCTAssertEqual(apiHandlerMock.callCdbAdUnits?.first, adUnit)
    XCTAssertFalse(cacheManagerMock.removeBidWasCalled)
    do {
      let isEmpty = try XCTUnwrap(bidReceived?.isEmpty())
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
    let bidFetchExpectation = expectation(description: "Bid fetch finish expectation")
    let responseHandler: CR_CdbBidResponseHandler = { (_) -> Void in bidFetchExpectation.fulfill() }
    let bidReceived = dependencyProvider.bidManager.getBidThenFetch(adUnit, withContext: contextData, responseHandler: responseHandler)
    wait(for: [bidFetchExpectation], timeout: timeout)
    XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
    XCTAssertNil(apiHandlerMock.callCdbAdUnits)
    do {
      let isEmpty = try XCTUnwrap(bidReceived?.isEmpty())
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
    let bidSilenced = createBid(adUnit: adUnit, types: [.silenced])
    dependencyProvider.cacheManager.bidCache[adUnit] = bidSilenced

    apiHandlerMock.reset()
    let bidFetchExpectation = expectation(description: "Bid fetch finish expectation")
    let responseHandler: CR_CdbBidResponseHandler = { (_) -> Void in bidFetchExpectation.fulfill() }
    let bidReceived = dependencyProvider.bidManager.getBidThenFetch(adUnit, withContext: contextData, responseHandler: responseHandler)
    wait(for: [bidFetchExpectation], timeout: timeout)
    XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
    XCTAssertNil(apiHandlerMock.callCdbAdUnits)
    do {
      let isEmpty = try XCTUnwrap(bidReceived?.isEmpty())
      XCTAssertTrue(isEmpty)
    } catch {
      XCTFail("Variable bid is nil!")
    }
  }

  /// Having an expired silenced ad unit, having a cached bid, when fetching a new bid, the expectation is to get the initial cached bid.
  func testGetBidForBidWithSilencedModeElapsed() {

    let adUnit = createAdUnit()
    let bidExpired = createBid(adUnit: adUnit, types: [.expired])
    dependencyProvider.cacheManager.bidCache[adUnit] = bidExpired

    apiHandlerMock.reset()
    let bidFetchExpectation = expectation(description: "Bid fetch finish expectation")
    let responseHandler: CR_CdbBidResponseHandler = { (_) -> Void in bidFetchExpectation.fulfill() }
    let bidReceived = dependencyProvider.bidManager.getBidThenFetch(adUnit, withContext: contextData, responseHandler: responseHandler)
    wait(for: [bidFetchExpectation], timeout: timeout)
    XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
    XCTAssertEqual(apiHandlerMock.callCdbAdUnits?.first, adUnit)
    do {
      let isEmpty = try XCTUnwrap(bidReceived?.isEmpty())
      XCTAssertTrue(isEmpty)
    } catch {
      XCTFail("Variable bid is nil!")
    }
  }

  /// Having a no-bid cached bid, when fetching a new bid, the expectation is to get the initial empty cached bid.
  func testGetBidWhenNoBid() {

    let adUnit = createAdUnit()
    let bidNoBid = createBid(adUnit: adUnit, types: [.noBid])
    dependencyProvider.cacheManager.bidCache[adUnit] = bidNoBid

    apiHandlerMock.reset()
    let bidFetchExpectation = expectation(description: "Bid fetch finish expectation")
    let responseHandler: CR_CdbBidResponseHandler = { (_) -> Void in bidFetchExpectation.fulfill() }
    let bidReceived = dependencyProvider.bidManager.getBidThenFetch(adUnit, withContext: contextData, responseHandler: responseHandler)
    wait(for: [bidFetchExpectation], timeout: timeout)
    XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
    XCTAssertEqual(apiHandlerMock.callCdbAdUnits?.first, adUnit)
    do {
      let isEmpty = try XCTUnwrap(bidReceived?.isEmpty())
      XCTAssertTrue(isEmpty)
    } catch {
      XCTFail("Variable bid is nil!")
    }
  }

  /// Having an expired cached bid, when fetching a new bid, the expectation is to get the initial empty cached bid.
  func testGetBidWhenBidExpired() {

    let adUnit = createAdUnit()
    let bidExpired = createBid(adUnit: adUnit, types: [.expired])
    dependencyProvider.cacheManager.bidCache[adUnit] = bidExpired

    apiHandlerMock.reset()
    XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
    XCTAssertNil(apiHandlerMock.callCdbAdUnits)
    let bidFetchExpectation = expectation(description: "Bid fetch finish expectation")
    let responseHandler: CR_CdbBidResponseHandler = { (_) -> Void in bidFetchExpectation.fulfill() }
    let bidReceived = dependencyProvider.bidManager.getBidThenFetch(adUnit, withContext: contextData, responseHandler: responseHandler)
    wait(for: [bidFetchExpectation], timeout: timeout)
    XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
    XCTAssertEqual(apiHandlerMock.callCdbAdUnits?.first, adUnit)
    do {
      let isEmpty = try XCTUnwrap(bidReceived?.isEmpty())
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


  // MARK: - Tests for Live Bidding

  /// Having a cached bid, when fetching a live bid, the expectation is to get a different bid than the initial cached bid.
  func testLiveBid_GivenResponseBeforeTimeBudget_ThenBidFromResponseGiven() {

    let adUnit = createAdUnit()
    let bidCached = createBid(adUnit: adUnit)
    let bidImmediate = createBid(adUnit: adUnit, types: [.immediate])

    apiHandlerMock.reset()
    cacheManagerMock.bidCache[adUnit] = bidCached
    cdbResponseMock.cdbBids = [bidImmediate]
    feedbackDelegateMock.reset()
    synchronousThreadManager.isTimeout = false

    let currentQueue = OperationQueue.current?.underlyingQueue

    let fetchLiveBidExpectation = expectation(description: "Fetch live bid finish expectation")
    dependencyProvider.bidManager.fetchLiveBid(for: adUnit, withContext: contextData) { [unowned self] bidReceived in

      currentQueue?.async { [unowned self] in

        fetchLiveBidExpectation.fulfill()

        XCTAssertEqual(bidReceived, bidImmediate)

        XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
        XCTAssertEqual(apiHandlerMock.callCdbAdUnits, [adUnit])

        XCTAssertFalse(cacheManagerMock.setBidWasCalled)
        XCTAssertNil(cacheManagerMock.setBidWasCalledWithBid)

        XCTAssertFalse(feedbackDelegateMock.onBidCachedWasCalled)
        XCTAssertNil(feedbackDelegateMock.onBidCachedWasCalledWithBid)

        XCTAssertTrue(feedbackDelegateMock.onBidConsumedWasCalled)
        XCTAssertEqual(feedbackDelegateMock.onBidConsumedWasCalledWithBid, bidImmediate)
      }
    }

    wait(for: [fetchLiveBidExpectation], timeout: timeout)

    do {
      let bidCached = try XCTUnwrap(dependencyProvider.cacheManager.bidCache[adUnit] as? CR_CdbBid)
      XCTAssertNotEqual(bidCached, bidImmediate)
    } catch {
      XCTFail("Failed to retrieve cached bid!")
    }
  }

  /// Having time budget exceeded, when fetching a live bid, the expectation is to get a new bid and cache it.
  func testLiveBid_GivenResponseAfterTimeBudget_ThenBidFromCacheGiven() {

    let adUnit = createAdUnit()
    let bidCached = createBid(adUnit: adUnit)
    let bidImmediate = createBid(adUnit: adUnit, types: [.immediate])

    apiHandlerMock.reset()
    cdbResponseMock.cdbBids = [bidImmediate]
    cacheManagerMock.bidCache[adUnit] = bidCached
    feedbackDelegateMock.reset()
    synchronousThreadManager.isTimeout = true

    let currentQueue = OperationQueue.current?.underlyingQueue

    let fetchLiveBidExpectation = expectation(description: "Fetch live bid finish expectation")
    dependencyProvider.bidManager.fetchLiveBid(for: adUnit, withContext: contextData) { [unowned self] bidReceived in

      currentQueue?.async { [unowned self] in

        fetchLiveBidExpectation.fulfill()

        XCTAssertEqual(bidReceived, bidCached)

        XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
        XCTAssertEqual(apiHandlerMock.callCdbAdUnits, [adUnit])

        XCTAssertTrue(cacheManagerMock.setBidWasCalled)
        XCTAssertEqual(cacheManagerMock.setBidWasCalledWithBid, bidImmediate)

        XCTAssertTrue(feedbackDelegateMock.onBidCachedWasCalled)
        XCTAssertEqual(feedbackDelegateMock.onBidCachedWasCalledWithBid, bidImmediate)

        XCTAssertTrue(feedbackDelegateMock.onBidConsumedWasCalled)
        XCTAssertEqual(feedbackDelegateMock.onBidConsumedWasCalledWithBid, bidCached)
      }
    }

    wait(for: [fetchLiveBidExpectation], timeout: timeout)
  }

  /// Having a cached bid, having no bid returned from fetching, the expectation is to use the initial cached bid.
  func testLiveBid_GivenResponseError_ThenBidFromCacheGiven() {

    let adUnit = createAdUnit()
    let bidCached = createBid(adUnit: adUnit)

    apiHandlerMock.reset()
    XCTAssertNil(apiHandlerMock.callCdbCdbResponse)
    cacheManagerMock.bidCache[adUnit] = bidCached
    feedbackDelegateMock.reset()

    let currentQueue = OperationQueue.current?.underlyingQueue

    let fetchLiveBidExpectation = expectation(description: "Fetch live bid finish expectation")
    dependencyProvider.bidManager.fetchLiveBid(for: adUnit, withContext: contextData) { [unowned self] bidReceived in

      currentQueue?.async { [unowned self] in

        fetchLiveBidExpectation.fulfill()

        XCTAssertEqual(bidReceived, bidCached)

        XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
        XCTAssertEqual(apiHandlerMock.callCdbAdUnits, [adUnit])

        XCTAssertFalse(cacheManagerMock.setBidWasCalled)
        XCTAssertNil(cacheManagerMock.setBidWasCalledWithBid)

        XCTAssertFalse(feedbackDelegateMock.onBidCachedWasCalled)
        XCTAssertNil(feedbackDelegateMock.onBidCachedWasCalledWithBid)

        XCTAssertTrue(feedbackDelegateMock.onBidConsumedWasCalled)
        XCTAssertEqual(feedbackDelegateMock.onBidConsumedWasCalledWithBid, bidCached)
      }
    }

    wait(for: [fetchLiveBidExpectation], timeout: timeout)
  }

  /// Having no cached bid, having a bid returned from fetching, the expectation is to cache the fetched bid.
  func testLiveBid_GivenResponseAfterTimeBudgetAndNoBidInCache_ThenNoBidGiven() {

    let adUnit1 = createAdUnit()
    let adUnit2 = createAdUnit()
    let bidLive = createBid(adUnit: adUnit1)

    apiHandlerMock.reset()
    cacheManagerMock.reset()
    cdbResponseMock.cdbBids = [bidLive]
    feedbackDelegateMock.reset()
    synchronousThreadManager.isTimeout = true

    let currentQueue = OperationQueue.current?.underlyingQueue

    let fetchLiveBidExpectation = expectation(description: "Fetch live bid finish expectation")
    dependencyProvider.bidManager.fetchLiveBid(for: adUnit2, withContext: contextData) { [unowned self] bidReceived in

      currentQueue?.async { [unowned self] in

        fetchLiveBidExpectation.fulfill()

        XCTAssertTrue(bidReceived?.isEmpty() ?? true)  // By having "?? true" basically means the bid is nil or empty

        XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
        XCTAssertEqual(apiHandlerMock.callCdbAdUnits, [adUnit2])

        XCTAssertTrue(cacheManagerMock.setBidWasCalled)
        XCTAssertEqual(cacheManagerMock.setBidWasCalledWithBid, bidLive)

        XCTAssertTrue(feedbackDelegateMock.onBidCachedWasCalled)
        XCTAssertEqual(feedbackDelegateMock.onBidCachedWasCalledWithBid, bidLive)

        XCTAssertFalse(feedbackDelegateMock.onBidConsumedWasCalled)
        XCTAssertNil(feedbackDelegateMock.onBidConsumedWasCalledWithBid)
      }
    }

    wait(for: [fetchLiveBidExpectation], timeout: timeout)
  }

  /// Having no cached bid, having no bid returned from fetching, the expectation is to receive no bid, cache no bid, consume no bid.
  func testLiveBid_GivenResponseErrorAfterTimeBudgetAndNoBidInCache_ThenNoBidGiven() {

    let adUnit = createAdUnit()

    apiHandlerMock.reset()
    XCTAssertNil(apiHandlerMock.callCdbCdbResponse)
    cacheManagerMock.reset()
    feedbackDelegateMock.reset()
    synchronousThreadManager.isTimeout = true

    let currentQueue = OperationQueue.current?.underlyingQueue

    let fetchLiveBidExpectation = expectation(description: "Fetch live bid finish expectation")
    dependencyProvider.bidManager.fetchLiveBid(for: adUnit, withContext: contextData) { [unowned self] bidReceived in

      currentQueue?.async { [unowned self] in

        fetchLiveBidExpectation.fulfill()

        XCTAssertTrue(bidReceived?.isEmpty() ?? true)  // By having "?? true" basically means the bid is nil or empty

        XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
        XCTAssertEqual(apiHandlerMock.callCdbAdUnits, [adUnit])

        XCTAssertFalse(cacheManagerMock.setBidWasCalled)
        XCTAssertNil(cacheManagerMock.setBidWasCalledWithBid)

        XCTAssertFalse(feedbackDelegateMock.onBidCachedWasCalled)
        XCTAssertNil(feedbackDelegateMock.onBidCachedWasCalledWithBid)

        XCTAssertFalse(feedbackDelegateMock.onBidConsumedWasCalled)
        XCTAssertNil(feedbackDelegateMock.onBidConsumedWasCalledWithBid)
      }
    }

    wait(for: [fetchLiveBidExpectation], timeout: timeout)
  }

  /// Having no cached bid, having no bid returned from fetching, the expectation is to receive no bid, cache no bid, consume no bid.
  func testLiveBid_GivenResponseErrorAndNoBidInCache_ThenNoBidGiven() {

    let adUnit = createAdUnit()

    apiHandlerMock.reset()
    XCTAssertNil(apiHandlerMock.callCdbCdbResponse)
    cacheManagerMock.reset()
    feedbackDelegateMock.reset()

    let currentQueue = OperationQueue.current?.underlyingQueue

    let fetchLiveBidExpectation = expectation(description: "Fetch live bid finish expectation")
    dependencyProvider.bidManager.fetchLiveBid(for: adUnit, withContext: contextData) { [unowned self] bidReceived in

      currentQueue?.async { [unowned self] in

        fetchLiveBidExpectation.fulfill()

        XCTAssertTrue(bidReceived?.isEmpty() ?? true) // By having "?? true" basically means the bid is nil or empty

        XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
        XCTAssertEqual(apiHandlerMock.callCdbAdUnits, [adUnit])

        XCTAssertFalse(cacheManagerMock.setBidWasCalled)
        XCTAssertNil(cacheManagerMock.setBidWasCalledWithBid)

        XCTAssertFalse(feedbackDelegateMock.onBidCachedWasCalled)
        XCTAssertNil(feedbackDelegateMock.onBidCachedWasCalledWithBid)

        XCTAssertFalse(feedbackDelegateMock.onBidConsumedWasCalled)
        XCTAssertNil(feedbackDelegateMock.onBidConsumedWasCalledWithBid)
      }
    }

    wait(for: [fetchLiveBidExpectation], timeout: timeout)
  }

  /// Having an expired cached bid, when fetching a live bid, the expectation is to get a new bid and consume the initial cached expired bid.
  func testLiveBid_GivenResponseAfterTimeBudgetAndExpiredBidInCache_ThenNoBidGiven() {

    let adUnit = createAdUnit()
    let bidCachedExpired = createBid(adUnit: adUnit, types: [.expired])
    let bidValid = createBid(adUnit: adUnit)

    apiHandlerMock.reset()
    cacheManagerMock.bidCache[adUnit] = bidCachedExpired
    cdbResponseMock.cdbBids = [bidValid]
    feedbackDelegateMock.reset()
    synchronousThreadManager.isTimeout = true

    let currentQueue = OperationQueue.current?.underlyingQueue

    let fetchLiveBidExpectation = expectation(description: "Fetch live bid finish expectation")
    dependencyProvider.bidManager.fetchLiveBid(for: adUnit, withContext: contextData) { [unowned self] bidReceived in

      currentQueue?.async { [unowned self] in

        fetchLiveBidExpectation.fulfill()

        XCTAssertTrue(bidReceived?.isEmpty() ?? true) // By having "?? true" basically means the bid is nil or empty

        XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
        XCTAssertEqual(apiHandlerMock.callCdbAdUnits, [adUnit])

        XCTAssertTrue(cacheManagerMock.setBidWasCalled)
        XCTAssertEqual(cacheManagerMock.setBidWasCalledWithBid, bidValid)

        XCTAssertTrue(feedbackDelegateMock.onBidCachedWasCalled)
        XCTAssertEqual(feedbackDelegateMock.onBidCachedWasCalledWithBid, bidValid)

        XCTAssertTrue(feedbackDelegateMock.onBidConsumedWasCalled)
        XCTAssertEqual(feedbackDelegateMock.onBidConsumedWasCalledWithBid, bidCachedExpired)
      }
    }

    wait(for: [fetchLiveBidExpectation], timeout: timeout)
  }

  /// Having an expired cached bid, having no bid returned from fetching, the expectation is to receive no bid, cache no bid and consume the initial cached expired bid.
  func testLiveBid_GivenResponseErrorAndExpiredBidInCache_ThenNoBidGiven() {

    let adUnit = createAdUnit()
    let bidCachedExpired = createBid(adUnit: adUnit, types: [.expired])

    apiHandlerMock.reset()
    XCTAssertNil(apiHandlerMock.callCdbCdbResponse)
    cacheManagerMock.bidCache[adUnit] = bidCachedExpired
    feedbackDelegateMock.reset()

    let currentQueue = OperationQueue.current?.underlyingQueue

    let fetchLiveBidExpectation = expectation(description: "Fetch live bid finish expectation")
    dependencyProvider.bidManager.fetchLiveBid(for: adUnit, withContext: contextData) { [unowned self] bidReceived in

      currentQueue?.async { [unowned self] in

        fetchLiveBidExpectation.fulfill()

        XCTAssertTrue(bidReceived?.isEmpty() ?? true) // By having "?? true" basically means the bid is nil or empty

        XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
        XCTAssertEqual(apiHandlerMock.callCdbAdUnits, [adUnit])

        XCTAssertFalse(cacheManagerMock.setBidWasCalled)
        XCTAssertNil(cacheManagerMock.setBidWasCalledWithBid)

        XCTAssertFalse(feedbackDelegateMock.onBidCachedWasCalled)
        XCTAssertNil(feedbackDelegateMock.onBidCachedWasCalledWithBid)

        XCTAssertTrue(feedbackDelegateMock.onBidConsumedWasCalled)
        XCTAssertEqual(feedbackDelegateMock.onBidConsumedWasCalledWithBid, bidCachedExpired)
      }
    }

    wait(for: [fetchLiveBidExpectation], timeout: timeout)
  }

  /// Having an expired cached bid, having no bid returned from fetching, the expectation is to receive no bid, cache no bid and consume the initial cached expired bid.
  func testLiveBid_GivenResponseErrorAfterTimeBudgetAndExpiredBidInCache_ThenNoBidGiven() {

    let adUnit = createAdUnit()
    let bidCachedExpired = createBid(adUnit: adUnit, types: [.expired])

    apiHandlerMock.reset()
    XCTAssertNil(apiHandlerMock.callCdbCdbResponse)
    cacheManagerMock.bidCache[adUnit] = bidCachedExpired
    feedbackDelegateMock.reset()
    synchronousThreadManager.isTimeout = true

    let currentQueue = OperationQueue.current?.underlyingQueue

    let fetchLiveBidExpectation = expectation(description: "Fetch live bid finish expectation")
    dependencyProvider.bidManager.fetchLiveBid(for: adUnit, withContext: contextData) { [unowned self] bidReceived in

      currentQueue?.async { [unowned self] in

        fetchLiveBidExpectation.fulfill()

        XCTAssertTrue(bidReceived?.isEmpty() ?? true) // By having "?? true" basically means the bid is nil or empty

        XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
        XCTAssertEqual(apiHandlerMock.callCdbAdUnits, [adUnit])

        XCTAssertFalse(cacheManagerMock.setBidWasCalled)
        XCTAssertNil(cacheManagerMock.setBidWasCalledWithBid)

        XCTAssertFalse(feedbackDelegateMock.onBidCachedWasCalled)
        XCTAssertNil(feedbackDelegateMock.onBidCachedWasCalledWithBid)

        XCTAssertTrue(feedbackDelegateMock.onBidConsumedWasCalled)
        XCTAssertEqual(feedbackDelegateMock.onBidConsumedWasCalledWithBid, bidCachedExpired)
      }
    }

    wait(for: [fetchLiveBidExpectation], timeout: timeout)
  }


  // MARK: - Tests for Silent User

  /// Having a silenced user, when fetching a live bid, the expectation is to receive no bid, cache no bid, consume no bid.
  func testLiveBid_GivenSilentMode_ThenCdbNotCalled_AndNoResponseGiven() {

    let adUnit = createAdUnit()

    apiHandlerMock.reset()
    cacheManagerMock.reset()
    feedbackDelegateMock.reset()
    dependencyProvider.bidManager.cdbTimeToNextCall = TimeInterval.infinity // silence user

    let currentQueue = OperationQueue.current?.underlyingQueue

    let fetchLiveBidExpectation = expectation(description: "Fetch live bid finish expectation")
    dependencyProvider.bidManager.fetchLiveBid(for: adUnit, withContext: contextData) { [unowned self] bidReceived in

      currentQueue?.async { [unowned self] in

        fetchLiveBidExpectation.fulfill()

        XCTAssertTrue(bidReceived?.isEmpty() ?? true) // By having "?? true" basically means the bid is nil or empty

        XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
        XCTAssertNil(apiHandlerMock.callCdbAdUnits)

        XCTAssertFalse(cacheManagerMock.setBidWasCalled)
        XCTAssertNil(cacheManagerMock.setBidWasCalledWithBid)

        XCTAssertFalse(feedbackDelegateMock.onBidCachedWasCalled)
        XCTAssertNil(feedbackDelegateMock.onBidCachedWasCalledWithBid)

        XCTAssertFalse(feedbackDelegateMock.onBidConsumedWasCalled)
        XCTAssertNil(feedbackDelegateMock.onBidConsumedWasCalledWithBid)
      }
    }

    wait(for: [fetchLiveBidExpectation], timeout: timeout)
  }

  /// Having a silenced user, having a cached bid, when fetching a live bid, the expectation is to receive the cached bid and consume the cached bid.
  func testLiveBid_GivenSilentModeAndValidBidInCache_ThenCdbNotCalled_AndResponseGiven() {

    let adUnit = createAdUnit()
    let bidCached = createBid(adUnit: adUnit)

    apiHandlerMock.reset()
    cacheManagerMock.bidCache[adUnit] = bidCached
    feedbackDelegateMock.reset()
    dependencyProvider.bidManager.cdbTimeToNextCall = TimeInterval.infinity // silence user

    let currentQueue = OperationQueue.current?.underlyingQueue

    let fetchLiveBidExpectation = expectation(description: "Fetch live bid finish expectation")
    dependencyProvider.bidManager.fetchLiveBid(for: adUnit, withContext: contextData) { [unowned self] bidReceived in

      currentQueue?.async { [unowned self] in

        fetchLiveBidExpectation.fulfill()

        XCTAssertEqual(bidReceived, bidCached)

        XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
        XCTAssertNil(apiHandlerMock.callCdbAdUnits)

        XCTAssertFalse(cacheManagerMock.setBidWasCalled)
        XCTAssertNil(cacheManagerMock.setBidWasCalledWithBid)

        XCTAssertFalse(feedbackDelegateMock.onBidCachedWasCalled)
        XCTAssertNil(feedbackDelegateMock.onBidCachedWasCalledWithBid)

        XCTAssertTrue(feedbackDelegateMock.onBidConsumedWasCalled)
        XCTAssertEqual(feedbackDelegateMock.onBidConsumedWasCalledWithBid, bidCached)
      }
    }

    wait(for: [fetchLiveBidExpectation], timeout: timeout)
  }

  /// Having a silenced user, having an expired cached bid, when fetching a live bid, the expectation is to consume the cached bid.
  func testLiveBid_GivenSilentModeAndExpiredBidInCache_ThenCdbNotCalled_AndNoResponseGiven() {

    let adUnit = createAdUnit()
    let bidCachedExpired = createBid(adUnit: adUnit, types: [.expired])

    apiHandlerMock.reset()
    cacheManagerMock.bidCache[adUnit] = bidCachedExpired
    feedbackDelegateMock.reset()
    dependencyProvider.bidManager.cdbTimeToNextCall = TimeInterval.infinity // silence user

    let currentQueue = OperationQueue.current?.underlyingQueue

    let fetchLiveBidExpectation = expectation(description: "Fetch live bid finish expectation")
    dependencyProvider.bidManager.fetchLiveBid(for: adUnit, withContext: contextData) { [unowned self] bidReceived in

      currentQueue?.async { [unowned self] in

        fetchLiveBidExpectation.fulfill()

        XCTAssertTrue(bidReceived?.isEmpty() ?? true) // By having "?? true" basically means the bid is nil or empty

        XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
        XCTAssertNil(apiHandlerMock.callCdbAdUnits)

        XCTAssertFalse(cacheManagerMock.setBidWasCalled)
        XCTAssertNil(cacheManagerMock.setBidWasCalledWithBid)

        XCTAssertFalse(feedbackDelegateMock.onBidCachedWasCalled)
        XCTAssertNil(feedbackDelegateMock.onBidCachedWasCalledWithBid)

        XCTAssertTrue(feedbackDelegateMock.onBidConsumedWasCalled)
        XCTAssertEqual(feedbackDelegateMock.onBidConsumedWasCalledWithBid, bidCachedExpired)
      }
    }

    wait(for: [fetchLiveBidExpectation], timeout: timeout)
  }

  /// Having a silenced user, having a no-bid cached bid, when fetching a live bid, the expectation is to consume the cached bid.
  func testLiveBid_GivenSilentModeAndNoBidInCache_ThenCdbNotCalled_AndNoResponseGiven() {

    let adUnit = createAdUnit()
    let bidNoBid = createBid(adUnit: adUnit, types: [.noBid])

    apiHandlerMock.reset()
    cacheManagerMock.bidCache[adUnit] = bidNoBid
    feedbackDelegateMock.reset()
    dependencyProvider.bidManager.cdbTimeToNextCall = TimeInterval.infinity // silence user

    let currentQueue = OperationQueue.current?.underlyingQueue

    let fetchLiveBidExpectation = expectation(description: "Fetch live bid finish expectation")
    dependencyProvider.bidManager.fetchLiveBid(for: adUnit, withContext: contextData) { [unowned self] bidReceived in

      currentQueue?.async { [unowned self] in

        fetchLiveBidExpectation.fulfill()

        XCTAssertTrue(bidReceived?.isEmpty() ?? true) // By having "?? true" basically means the bid is nil or empty

        XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
        XCTAssertNil(apiHandlerMock.callCdbAdUnits)

        XCTAssertFalse(cacheManagerMock.setBidWasCalled)
        XCTAssertNil(cacheManagerMock.setBidWasCalledWithBid)

        XCTAssertFalse(feedbackDelegateMock.onBidCachedWasCalled)
        XCTAssertNil(feedbackDelegateMock.onBidCachedWasCalledWithBid)

        XCTAssertTrue(feedbackDelegateMock.onBidConsumedWasCalled)
        XCTAssertEqual(feedbackDelegateMock.onBidConsumedWasCalledWithBid, bidNoBid)
      }
    }

    wait(for: [fetchLiveBidExpectation], timeout: timeout)
  }

  /// Having a silenced user, having no cached bid, when fetching a live bid, the expectation is to receive no bid, cache no bid and consume no bid.
  func testLiveBid_GivenSilentModeAndEmptyCache_ThenCdbNotCalled_AndNoResponseGiven() {

    let adUnit = createAdUnit()

    apiHandlerMock.reset()
    cacheManagerMock.reset()
    feedbackDelegateMock.reset()
    dependencyProvider.bidManager.cdbTimeToNextCall = TimeInterval.infinity // silence user

    let currentQueue = OperationQueue.current?.underlyingQueue

    let fetchLiveBidExpectation = expectation(description: "Fetch live bid finish expectation")
    dependencyProvider.bidManager.fetchLiveBid(for: adUnit, withContext: contextData) { [unowned self] bidReceived in

      currentQueue?.async { [unowned self] in

        fetchLiveBidExpectation.fulfill()

        XCTAssertTrue(bidReceived?.isEmpty() ?? true) // By having "?? true" basically means the bid is nil or empty

        XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
        XCTAssertNil(apiHandlerMock.callCdbAdUnits)

        XCTAssertFalse(cacheManagerMock.setBidWasCalled)
        XCTAssertNil(cacheManagerMock.setBidWasCalledWithBid)

        XCTAssertFalse(feedbackDelegateMock.onBidCachedWasCalled)
        XCTAssertNil(feedbackDelegateMock.onBidCachedWasCalledWithBid)

        XCTAssertFalse(feedbackDelegateMock.onBidConsumedWasCalled)
        XCTAssertNil(feedbackDelegateMock.onBidConsumedWasCalledWithBid)
      }
    }

    wait(for: [fetchLiveBidExpectation], timeout: timeout)
  }

  /// Having a silenced user, having a silenced cached bid, when fetching a live bid, the expectation is to receive no bid, cache no bid and consume no bid.
  func testLiveBid_GivenSilentModeAndSilentBidInCache_ThenCdbNotCalled_AndNoResponseGiven() {

    let adUnit = createAdUnit()
    let bidSilenced = createBid(adUnit: adUnit, types: [.silenced])

    apiHandlerMock.reset()
    cacheManagerMock.bidCache[adUnit] = bidSilenced
    feedbackDelegateMock.reset()
    dependencyProvider.bidManager.cdbTimeToNextCall = TimeInterval.infinity // silence user

    let currentQueue = OperationQueue.current?.underlyingQueue

    let fetchLiveBidExpectation = expectation(description: "Fetch live bid finish expectation")
    dependencyProvider.bidManager.fetchLiveBid(for: adUnit, withContext: contextData) { [unowned self] bidReceived in

      currentQueue?.async { [unowned self] in

        fetchLiveBidExpectation.fulfill()

        XCTAssertTrue(bidReceived?.isEmpty() ?? true) // By having "?? true" basically means the bid is nil or empty

        XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
        XCTAssertNil(apiHandlerMock.callCdbAdUnits)

        XCTAssertFalse(cacheManagerMock.setBidWasCalled)
        XCTAssertNil(cacheManagerMock.setBidWasCalledWithBid)

        XCTAssertFalse(feedbackDelegateMock.onBidCachedWasCalled)
        XCTAssertNil(feedbackDelegateMock.onBidCachedWasCalledWithBid)

        XCTAssertFalse(feedbackDelegateMock.onBidConsumedWasCalled)
        XCTAssertNil(feedbackDelegateMock.onBidConsumedWasCalledWithBid)
      }
    }

    wait(for: [fetchLiveBidExpectation], timeout: timeout)

    do {
      let bidCached = try XCTUnwrap(dependencyProvider.cacheManager.bidCache[adUnit] as? CR_CdbBid)
      XCTAssertEqual(bidCached, bidSilenced)
    } catch {
      XCTFail("Failed to retrieve cached bid!")
    }
  }

  /// Having a de-silenced user, having a cached bid, when fetching a live bid, the expectation is to receive the cached bid.
  func testLiveBid_GivenExpiredSilentMode_ThenCdbCalled_AndResponseGiven() {

    let adUnit = createAdUnit()
    let bidValid = createBid(adUnit: adUnit)

    apiHandlerMock.reset()
    cacheManagerMock.bidCache[adUnit] = bidValid
    dependencyProvider.bidManager.cdbTimeToNextCall = Date(timeIntervalSinceNow: -1).timeIntervalSinceReferenceDate // expired user silent, 1s before now
    feedbackDelegateMock.reset()

    let currentQueue = OperationQueue.current?.underlyingQueue

    let fetchLiveBidExpectation = expectation(description: "Fetch live bid finish expectation")
    dependencyProvider.bidManager.fetchLiveBid(for: adUnit, withContext: contextData) { [unowned self] bidReceived in

      currentQueue?.async { [unowned self] in

        fetchLiveBidExpectation.fulfill()

        XCTAssertEqual(bidReceived, bidValid)

        XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
        XCTAssertEqual(apiHandlerMock.callCdbAdUnits, [adUnit])

        XCTAssertFalse(cacheManagerMock.setBidWasCalled)
        XCTAssertNil(cacheManagerMock.setBidWasCalledWithBid)

        XCTAssertFalse(feedbackDelegateMock.onBidCachedWasCalled)
        XCTAssertNil(feedbackDelegateMock.onBidCachedWasCalledWithBid)

        XCTAssertFalse(feedbackDelegateMock.onBidConsumedWasCalled)
        XCTAssertNil(feedbackDelegateMock.onBidConsumedWasCalledWithBid)
      }
    }

    wait(for: [fetchLiveBidExpectation], timeout: timeout)
  }

  /// Having a cached bid, having no bid returned from fetching, the expectation is to receive the cached bid.
  func testLiveBid_GivenResponseErrorAndSilentModeAndValidBidInCache_ThenResponseGiven() {

    let adUnit = createAdUnit()
    let bidValid = createBid(adUnit: adUnit)

    apiHandlerMock.reset()
    XCTAssertNil(apiHandlerMock.callCdbCdbResponse)
    apiHandlerMock.callCdbBeforeCdbResponseBlock = { [unowned self] in
      dependencyProvider.bidManager.cdbTimeToNextCall = TimeInterval.infinity // silence user
    }
    cacheManagerMock.bidCache[adUnit] = bidValid
    feedbackDelegateMock.reset()

    let currentQueue = OperationQueue.current?.underlyingQueue

    let fetchLiveBidExpectation = expectation(description: "Fetch live bid finish expectation")
    dependencyProvider.bidManager.fetchLiveBid(for: adUnit, withContext: contextData) { [unowned self] bidReceived in

      currentQueue?.async { [unowned self] in

        fetchLiveBidExpectation.fulfill()

        XCTAssertEqual(bidReceived, bidValid)

        XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
        XCTAssertEqual(apiHandlerMock.callCdbAdUnits, [adUnit])

        XCTAssertFalse(cacheManagerMock.setBidWasCalled)
        XCTAssertNil(cacheManagerMock.setBidWasCalledWithBid)

        XCTAssertFalse(feedbackDelegateMock.onBidCachedWasCalled)
        XCTAssertNil(feedbackDelegateMock.onBidCachedWasCalledWithBid)

        XCTAssertTrue(feedbackDelegateMock.onBidConsumedWasCalled)
        XCTAssertEqual(feedbackDelegateMock.onBidConsumedWasCalledWithBid, bidValid)
      }
    }

    wait(for: [fetchLiveBidExpectation], timeout: timeout)
  }

  /// Having the user silenced with the next fetch, the expectation is to receive, cache, consume no bid and update the bid manager accordingly.
  func testLiveBid_GivenSilentUserResponse_ThenUserSilenceUpdated() {

    let adUnit = createAdUnit()

    cacheManagerMock.reset()
    cdbResponseMock.timeToNextCall = 123 // silence user starting with the next fetch
    feedbackDelegateMock.reset()

    let currentQueue = OperationQueue.current?.underlyingQueue

    let fetchLiveBidExpectation = expectation(description: "Fetch live bid finish expectation")
    dependencyProvider.bidManager.fetchLiveBid(for: adUnit, withContext: contextData) { [unowned self] bidReceived in

      currentQueue?.async { [unowned self] in

        fetchLiveBidExpectation.fulfill()

        XCTAssertTrue(bidReceived?.isEmpty() ?? true) // By having "?? true" basically means the bid is nil or empty

        XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
        XCTAssertEqual(apiHandlerMock.callCdbAdUnits, [adUnit])

        XCTAssertFalse(cacheManagerMock.setBidWasCalled)
        XCTAssertNil(cacheManagerMock.setBidWasCalledWithBid)

        XCTAssertFalse(feedbackDelegateMock.onBidCachedWasCalled)
        XCTAssertNil(feedbackDelegateMock.onBidCachedWasCalledWithBid)

        XCTAssertFalse(feedbackDelegateMock.onBidConsumedWasCalled)
        XCTAssertNil(feedbackDelegateMock.onBidConsumedWasCalledWithBid)
      }
    }

    wait(for: [fetchLiveBidExpectation], timeout: timeout)

    XCTAssertTrue(dependencyProvider.bidManager.isInSilenceMode())
  }

  /// Having the user silenced with the next fetch, having time elapsed, the expectation is to receive, cache, consume no bid and update the bid manager accordingly.
  func testLiveBid_GivenSilentUserResponseAfterTimeBudget_ThenUserSilenceUpdated() {

    let adUnit = createAdUnit()

    cacheManagerMock.reset()
    cdbResponseMock.timeToNextCall = 123 // silence user starting with the next fetch
    feedbackDelegateMock.reset()
    synchronousThreadManager.isTimeout = true

    let currentQueue = OperationQueue.current?.underlyingQueue

    let fetchLiveBidExpectation = expectation(description: "Fetch live bid finish expectation")
    dependencyProvider.bidManager.fetchLiveBid(for: adUnit, withContext: contextData) { [unowned self] bidReceived in

      currentQueue?.async { [unowned self] in

        fetchLiveBidExpectation.fulfill()

        XCTAssertTrue(bidReceived?.isEmpty() ?? true) // By having "?? true" basically means the bid is nil or empty

        XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
        XCTAssertEqual(apiHandlerMock.callCdbAdUnits, [adUnit])

        XCTAssertFalse(cacheManagerMock.setBidWasCalled)
        XCTAssertNil(cacheManagerMock.setBidWasCalledWithBid)

        XCTAssertFalse(feedbackDelegateMock.onBidCachedWasCalled)
        XCTAssertNil(feedbackDelegateMock.onBidCachedWasCalledWithBid)

        XCTAssertFalse(feedbackDelegateMock.onBidConsumedWasCalled)
        XCTAssertNil(feedbackDelegateMock.onBidConsumedWasCalledWithBid)
      }
    }

    wait(for: [fetchLiveBidExpectation], timeout: timeout)

    XCTAssertTrue(dependencyProvider.bidManager.isInSilenceMode())
  }

  /// Having the user silenced midway fetching, when fetching a live bid and receiving a valid bid, the expectation is to consume the received bid and update the bid manager accordingly.
  func testLiveBid_GivenNotSilentUserResponse_ThenUserSilenceNotUpdated() {

    let adUnit = createAdUnit()
    let bidValid = createBid(adUnit: adUnit)

    apiHandlerMock.reset()
    apiHandlerMock.callCdbBeforeCdbResponseBlock = { [unowned self] in
      dependencyProvider.bidManager.cdbTimeToNextCall = TimeInterval.infinity // silence user
    }
    cdbResponseMock.cdbBids = [bidValid]
    cacheManagerMock.reset()
    feedbackDelegateMock.reset()

    let currentQueue = OperationQueue.current?.underlyingQueue

    let fetchLiveBidExpectation = expectation(description: "Fetch live bid finish expectation")
    dependencyProvider.bidManager.fetchLiveBid(for: adUnit, withContext: contextData) { [unowned self] bidReceived in

      currentQueue?.async { [unowned self] in

        fetchLiveBidExpectation.fulfill()

        XCTAssertEqual(bidReceived, bidValid)

        XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
        XCTAssertEqual(apiHandlerMock.callCdbAdUnits, [adUnit])

        XCTAssertFalse(cacheManagerMock.setBidWasCalled)
        XCTAssertNil(cacheManagerMock.setBidWasCalledWithBid)

        XCTAssertFalse(feedbackDelegateMock.onBidCachedWasCalled)
        XCTAssertNil(feedbackDelegateMock.onBidCachedWasCalledWithBid)

        XCTAssertTrue(feedbackDelegateMock.onBidConsumedWasCalled)
        XCTAssertEqual(feedbackDelegateMock.onBidConsumedWasCalledWithBid, bidValid)
      }
    }

    wait(for: [fetchLiveBidExpectation], timeout: timeout)

    XCTAssertTrue(dependencyProvider.bidManager.isInSilenceMode())
  }

  /// Having the user silenced midway fetching, when fetching a live bid and receiving a valid bid, the expectation is to consume the received bid and update the bid manager accordingly.
  func testLiveBid_GivenNotSilentUserResponseAfterTimeBudget_ThenUserSilenceNotUpdated() {

    let adUnit = createAdUnit()
    let bidValid = createBid(adUnit: adUnit)

    apiHandlerMock.reset()
    apiHandlerMock.callCdbBeforeCdbResponseBlock = { [unowned self] in
      dependencyProvider.bidManager.cdbTimeToNextCall = TimeInterval.infinity // silence user
    }
    cdbResponseMock.cdbBids = [bidValid]
    cacheManagerMock.reset()
    feedbackDelegateMock.reset()

    let currentQueue = OperationQueue.current?.underlyingQueue

    let fetchLiveBidExpectation = expectation(description: "Fetch live bid finish expectation")
    dependencyProvider.bidManager.fetchLiveBid(for: adUnit, withContext: contextData) { [unowned self] bidReceived in

      currentQueue?.async { [unowned self] in

        fetchLiveBidExpectation.fulfill()

        XCTAssertEqual(bidReceived, bidValid)

        XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
        XCTAssertEqual(apiHandlerMock.callCdbAdUnits, [adUnit])

        XCTAssertFalse(cacheManagerMock.setBidWasCalled)
        XCTAssertNil(cacheManagerMock.setBidWasCalledWithBid)

        XCTAssertFalse(feedbackDelegateMock.onBidCachedWasCalled)
        XCTAssertNil(feedbackDelegateMock.onBidCachedWasCalledWithBid)

        XCTAssertTrue(feedbackDelegateMock.onBidConsumedWasCalled)
        XCTAssertEqual(feedbackDelegateMock.onBidConsumedWasCalledWithBid, bidValid)
      }
    }

    wait(for: [fetchLiveBidExpectation], timeout: timeout)

    XCTAssertTrue(dependencyProvider.bidManager.isInSilenceMode())
  }


  // MARK: - Tests for Consent Given

  /// Having no current consent, when fetching a live bid and receiving consent, current consent should be updated.
  func testLiveBid_GivenConsentGivenResponse_ThenConsentGivenUpdated() {

    let adUnit = createAdUnit()
    apiHandlerMock.reset()
    dependencyProvider.consent.isConsentGiven = false
    cdbResponseMock.consentGiven = true

    let currentQueue = OperationQueue.current?.underlyingQueue

    let fetchLiveBidExpectation = expectation(description: "Fetch live bid finish expectation")
    dependencyProvider.bidManager.fetchLiveBid(for: adUnit, withContext: contextData) { [unowned self] bidReceived in

      currentQueue?.async { [unowned self] in

        fetchLiveBidExpectation.fulfill()

        XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
        XCTAssertEqual(apiHandlerMock.callCdbAdUnits, [adUnit])
      }
    }

    wait(for: [fetchLiveBidExpectation], timeout: timeout)

    XCTAssertTrue(dependencyProvider.consent.isConsentGiven)
  }

  /// Having current consent, when fetching a live bid and retracting consent, current consent should be updated.
  func testLiveBid_GivenNoConsentGivenResponse_ThenConsentGivenUpdated() {

    let adUnit = createAdUnit()
    apiHandlerMock.reset()
    dependencyProvider.consent.isConsentGiven = true
    cdbResponseMock.consentGiven = false

    let currentQueue = OperationQueue.current?.underlyingQueue

    let fetchLiveBidExpectation = expectation(description: "Fetch live bid finish expectation")
    dependencyProvider.bidManager.fetchLiveBid(for: adUnit, withContext: contextData) { [unowned self] bidReceived in

      currentQueue?.async { [unowned self] in

        fetchLiveBidExpectation.fulfill()

        XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
        XCTAssertEqual(apiHandlerMock.callCdbAdUnits, [adUnit])
      }
    }

    wait(for: [fetchLiveBidExpectation], timeout: timeout)

    XCTAssertFalse(dependencyProvider.consent.isConsentGiven)
  }

  /// Having current consent, when fetching a live bid and receiving consent, current consent should stay the same.
  func testLiveBid_GivenConsentAndNotInResponse_ThenConsentGivenNotUpdated() {

    let adUnit = createAdUnit()
    apiHandlerMock.reset()
    dependencyProvider.consent.isConsentGiven = true
    // cdbResponseMock.consentGiven = nil // FIXME: Because of Swift conversion can't set to nil

    let currentQueue = OperationQueue.current?.underlyingQueue

    let fetchLiveBidExpectation = expectation(description: "Fetch live bid finish expectation")
    dependencyProvider.bidManager.fetchLiveBid(for: adUnit, withContext: contextData) { [unowned self] bidReceived in

      currentQueue?.async { [unowned self] in

        fetchLiveBidExpectation.fulfill()

        XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
        XCTAssertEqual(apiHandlerMock.callCdbAdUnits, [adUnit])
      }
    }

    wait(for: [fetchLiveBidExpectation], timeout: timeout)

    XCTAssertTrue(dependencyProvider.consent.isConsentGiven)
  }

  /// Having no current consent, when fetching a live bid and retracting consent, current consent should stay the same.
  func testLiveBid_GivenNoConsentAndNotInResponse_ThenConsentGivenNotUpdated() {

    let adUnit = createAdUnit()
    apiHandlerMock.reset()
    dependencyProvider.consent.isConsentGiven = false
    // cdbResponseMock.consentGiven = nil // FIXME: Because of Swift conversion can't set to nil

    let currentQueue = OperationQueue.current?.underlyingQueue

    let fetchLiveBidExpectation = expectation(description: "Fetch live bid finish expectation")
    dependencyProvider.bidManager.fetchLiveBid(for: adUnit, withContext: contextData) { [unowned self] bidReceived in

      currentQueue?.async { [unowned self] in

        fetchLiveBidExpectation.fulfill()

        XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
        XCTAssertEqual(apiHandlerMock.callCdbAdUnits, [adUnit])
      }
    }

    wait(for: [fetchLiveBidExpectation], timeout: timeout)

    XCTAssertFalse(dependencyProvider.consent.isConsentGiven)
  }

  /// Having no current consent, when fetching a live bid and receiving consent, current consent should be updated.
  func testLiveBid_GivenConsentGivenResponseAfterTimeBudget_ThenConsentGivenUpdated() {

    let adUnit = createAdUnit()
    apiHandlerMock.reset()
    dependencyProvider.consent.isConsentGiven = false
    cdbResponseMock.consentGiven = true
    synchronousThreadManager.isTimeout = true

    let currentQueue = OperationQueue.current?.underlyingQueue

    let fetchLiveBidExpectation = expectation(description: "Fetch live bid finish expectation")
    dependencyProvider.bidManager.fetchLiveBid(for: adUnit, withContext: contextData) { [unowned self] bidReceived in

      currentQueue?.async { [unowned self] in

        fetchLiveBidExpectation.fulfill()

        XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
        XCTAssertEqual(apiHandlerMock.callCdbAdUnits, [adUnit])
      }
    }

    wait(for: [fetchLiveBidExpectation], timeout: timeout)

    XCTAssertTrue(dependencyProvider.consent.isConsentGiven)
  }


  // MARK: - Tests for Silent Slot

  /// Having a cached bid, having no bid returned from fetching, the expectation is to receive no bid, cache no bid, consume no bid and keep the initial cached bid.
  func testLiveBid_GivenSilentBidInCache_ThenCdbNotCalledAndNoResponseGiven() {

    let adUnit = createAdUnit()
    let bidCachedSilenced = createBid(adUnit: adUnit, types: [.silenced])

    apiHandlerMock.reset()
    cacheManagerMock.bidCache[adUnit] = bidCachedSilenced
    feedbackDelegateMock.reset()

    let currentQueue = OperationQueue.current?.underlyingQueue

    let fetchLiveBidExpectation = expectation(description: "Fetch live bid finish expectation")
    dependencyProvider.bidManager.fetchLiveBid(for: adUnit, withContext: contextData) { [unowned self] bidReceived in

      currentQueue?.async { [unowned self] in

        fetchLiveBidExpectation.fulfill()

        XCTAssertTrue(bidReceived?.isEmpty() ?? true) // By having "?? true" basically means the bid is nil or empty

        XCTAssertFalse(apiHandlerMock.callCdbWasCalled)
        XCTAssertNil(apiHandlerMock.callCdbAdUnits)

        XCTAssertFalse(cacheManagerMock.setBidWasCalled)
        XCTAssertNil(cacheManagerMock.setBidWasCalledWithBid)

        XCTAssertFalse(feedbackDelegateMock.onBidCachedWasCalled)
        XCTAssertNil(feedbackDelegateMock.onBidCachedWasCalledWithBid)

        XCTAssertFalse(feedbackDelegateMock.onBidConsumedWasCalled)
        XCTAssertNil(feedbackDelegateMock.onBidConsumedWasCalledWithBid)
      }
    }

    wait(for: [fetchLiveBidExpectation], timeout: timeout)

    do {
      let bidCached = try XCTUnwrap(dependencyProvider.cacheManager.bidCache[adUnit] as? CR_CdbBid)
      XCTAssertEqual(bidCached, bidCachedSilenced)
    } catch {
      XCTFail("Failed to retrieve cached bid!")
    }
  }

  /// Having a cached silenced expired bid, when fetching a live bid and receiving a valid bid, the expectation is to consume the cached bid.
  func testLiveBid_GivenExpiredSilentBidInCache_ThenBidFromResponseGiven() {

    let adUnit = createAdUnit()
    let bidCachedExpiredSilenced = createBid(adUnit: adUnit, types: [.expired, .silenced])
    let bidValid = createBid(adUnit: adUnit)

    apiHandlerMock.reset()
    cacheManagerMock.bidCache[adUnit] = bidCachedExpiredSilenced
    cdbResponseMock.cdbBids = [bidValid]
    feedbackDelegateMock.reset()

    let currentQueue = OperationQueue.current?.underlyingQueue

    let fetchLiveBidExpectation = expectation(description: "Fetch live bid finish expectation")
    dependencyProvider.bidManager.fetchLiveBid(for: adUnit, withContext: contextData) { [unowned self] bidReceived in

      currentQueue?.async { [unowned self] in

        fetchLiveBidExpectation.fulfill()

        XCTAssertEqual(bidReceived, bidValid)

        XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
        XCTAssertEqual(apiHandlerMock.callCdbAdUnits, [adUnit])

        XCTAssertFalse(cacheManagerMock.setBidWasCalled)
        XCTAssertNil(cacheManagerMock.setBidWasCalledWithBid)

        XCTAssertFalse(feedbackDelegateMock.onBidCachedWasCalled)
        XCTAssertNil(feedbackDelegateMock.onBidCachedWasCalledWithBid)

        XCTAssertTrue(feedbackDelegateMock.onBidConsumedWasCalled)
        XCTAssertEqual(feedbackDelegateMock.onBidConsumedWasCalledWithBid, bidValid)
      }
    }

    wait(for: [fetchLiveBidExpectation], timeout: timeout)

    XCTAssertNil(dependencyProvider.cacheManager.bidCache[adUnit])
  }

  func testLiveBid_GivenSilentBid_ThenNoResponseGivenAndSlotSilenced() {

    let adUnit = createAdUnit()
    let bidSilenced = createBid(adUnit: adUnit, types: [.silenced])

    apiHandlerMock.reset()
    cacheManagerMock.reset()
    cdbResponseMock.cdbBids = [bidSilenced]
    feedbackDelegateMock.reset()
    logHandlerMock.reset()

    let currentQueue = OperationQueue.current?.underlyingQueue

    let fetchLiveBidExpectation = expectation(description: "Fetch live bid finish expectation")
    dependencyProvider.bidManager.fetchLiveBid(for: adUnit, withContext: contextData) { [unowned self] bidReceived in

      currentQueue?.async { [unowned self] in

        fetchLiveBidExpectation.fulfill()

        XCTAssertTrue(bidReceived?.isEmpty() ?? true) // By having "?? true" basically means the bid is nil or empty

        XCTAssertTrue(apiHandlerMock.callCdbWasCalled)
        XCTAssertEqual(apiHandlerMock.callCdbAdUnits, [adUnit])

        XCTAssertTrue(cacheManagerMock.setBidWasCalled)
        XCTAssertEqual(cacheManagerMock.setBidWasCalledWithBid, bidSilenced)

        XCTAssertTrue(feedbackDelegateMock.onBidCachedWasCalled)
        XCTAssertEqual(feedbackDelegateMock.onBidCachedWasCalledWithBid, bidSilenced)

        XCTAssertFalse(feedbackDelegateMock.onBidConsumedWasCalled)
        XCTAssertNil(feedbackDelegateMock.onBidConsumedWasCalledWithBid)
      }
    }

    wait(for: [fetchLiveBidExpectation], timeout: timeout)

    XCTAssertTrue(logHandlerMock.logMessageWasCalled)
  }
}
