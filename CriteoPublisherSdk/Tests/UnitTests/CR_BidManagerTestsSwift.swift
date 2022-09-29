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

  lazy var apiHandlerMock: CR_ApiHandlerMock = { return CR_ApiHandlerMock(dependencyProvider: dependencyProvider) }()

  lazy var bid1: CR_CdbBid = {
    let bidBuilder = CR_CdbBidBuilder() // FIXME: for some reason it gets nil unless stored as a separate variable
    return bidBuilder.adUnit(adUnit1).build
  }()

  lazy var bid2: CR_CdbBid = {
    let bidBuilder = CR_CdbBidBuilder() // FIXME: for some reason it gets nil unless stored as a separate variable
    return bidBuilder.adUnit(adUnit2).cpm("0.5").displayUrl("bid2.displayUrl").build
  }()

  lazy var bidManagerMock: CR_BidManagerMock = { return CR_BidManagerMock(dependencyProvider: dependencyProvider) }()

  lazy var bidRewarded: CR_CdbBid = {
    let bidBuilder = CR_CdbBidBuilder() // FIXME: for some reason it gets nil unless stored as a separate variable
    return bidBuilder.adUnit(adUnitRewarded).build
  }()

  lazy var cacheManagerMock: CR_CacheManagerMock = { return CR_CacheManagerMock() }()

  lazy var configManagerMock: CR_ConfigManagerMock = { return CR_ConfigManagerMock(dependencyProvider: dependencyProvider) }()

  lazy var contextData: CRContextData = { return CRContextData() }()

  lazy var dependencyProvider: CR_DependencyProvider = { return CR_DependencyProvider.testing() }()

//  lazy var threadManager: CR_SynchronousThreadManager = { return CR_SynchronousThreadManager() }() // TODO: Delete this maybe?

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
  }

  override func tearDown() {

//      [self.loggingMock stopMocking];
//      [self.dependencyProvider.feedbackStorage popMessagesToSend];

    super.tearDown()
  }


  // MARK: - Tests

  func testGetBidForCachedAdUnits() {

    dependencyProvider.apiHandler = apiHandlerMock
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

    dependencyProvider.apiHandler = apiHandlerMock

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

    dependencyProvider.apiHandler = apiHandlerMock
    dependencyProvider.cacheManager = cacheManagerMock

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

    dependencyProvider.apiHandler = apiHandlerMock
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

    dependencyProvider.apiHandler = apiHandlerMock
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

    dependencyProvider.apiHandler = apiHandlerMock

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

    dependencyProvider.apiHandler = apiHandlerMock

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

    dependencyProvider.apiHandler = apiHandlerMock

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

    dependencyProvider.apiHandler = apiHandlerMock

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

    dependencyProvider.bidManager = bidManagerMock
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

  
}
