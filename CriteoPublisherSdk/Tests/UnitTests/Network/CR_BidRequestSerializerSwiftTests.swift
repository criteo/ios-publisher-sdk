//
//  CR_BidRequestSerializerSwiftTests.swift
//  CriteoPublisherSdkTests
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

import XCTest

class CR_BidRequestSerializerSwiftTests: XCTestCase {

  var serializer: CR_BidRequestSerializer!
  var gdprSerializer: CR_GdprSerializerMock!
  var request: CR_CdbRequest!
  var userDataHolder = CR_UserDataHolder()
  var session = CR_Session(start: Date())
  lazy var internalContextProvider = CR_InternalContextProviderMock(session: session)

  var config: CR_Config = CR_Config()
  var consent: CR_DataProtectionConsentMock = CR_DataProtectionConsentMock()
  var deviceInfo: CR_DeviceInfoMock = CR_DeviceInfoMock()
  var context = CRContextData()
  var childDirectedTreatment: NSNumber?

  let userDefaults = CR_InMemoryUserDefaults()
  let testIntegrationType = CR_IntegrationType.gamAppBidding
  lazy var testProfileId = NSNumber(value: testIntegrationType.rawValue)

  override func setUp() {
    gdprSerializer = CR_GdprSerializerMock()
    serializer = CR_BidRequestSerializer(
      gdprSerializer: gdprSerializer,
      userDataHolder: userDataHolder,
      internalContextProvider: internalContextProvider)
    request = CR_CdbRequest(
      profileId: testProfileId,
      adUnits: [
        CR_CacheAdUnit(adUnitId: "1", width: 1, height: 1),
        CR_CacheAdUnit(adUnitId: "2", width: 2, height: 2)
      ])
    config.criteoPublisherId = "Test Published Id"
    config.inventoryGroupId = "Inventory Id"
  }

  func testUrl() {
    let expected = URL(string: "https://bidder.criteo.com/inapp/v2")

    let url = serializer.url(with: config)
    XCTAssertEqual(url, expected)
  }

  func testBodyWithSdkVersion() {
    let body = generateBody()
    XCTAssertEqual(body[NSString.sdkVersionKey] as? String, config.sdkVersion)
  }

  func testBodyWithProfileId() {
    let body = generateBody()
    XCTAssertEqual(body[NSString.profileIdKey] as? NSNumber, testProfileId)
  }

  func testBodyWithRequestGroupId() {
    let body = generateBody()
    XCTAssertEqual(body["id"] as? String, request.requestGroupId)
  }

  func testBodyWithPublisher() {
    let expected: NSDictionary = [
      NSString.bundleIdKey: config.appId,
      NSString.cpIdKey: config.criteoPublisherId!,
      NSString.pubIdKey: config.inventoryGroupId!,
      "ext": NSDictionary()
    ]
    let body = generateBody()
    XCTAssertEqual(body[NSString.publisherKey] as? NSDictionary, expected)
  }

  // MARK: User in body

  func testBodyWithUser() {
    let body = generateBody()
    let user: NSDictionary? = body[NSString.userKey] as? NSDictionary
    XCTAssertEqual(user?.count, 8)
    XCTAssertEqual(user?[NSString.userAgentKey] as? String, deviceInfo.userAgent)
    XCTAssertEqual(user?[NSString.deviceIdKey] as? String, deviceInfo.deviceId)
    XCTAssertEqual(user?[NSString.deviceOsKey] as? String, config.deviceOs)
    XCTAssertEqual(user?[NSString.deviceModelKey] as? String, config.deviceModel)
    XCTAssertEqual(user?[NSString.deviceIdTypeKey] as? String, NSString.deviceIdTypeValue)
    XCTAssertEqual(user?[NSString.uspIabKey] as? String, consent.usPrivacyIabConsentString!)
    XCTAssertEqual(user?["ext"] as? NSDictionary, NSDictionary())
    XCTAssertEqual(
      user?["skAdNetwork"] as? NSDictionary,
      ["versions": ["2.0", "2.1", "2.2", "3.0"], "skAdNetworkIds": ["hs6bdukanm.skadnetwork"]] as? NSDictionary)
  }

  func testBodyWithUsPrivacyConsentString() {
    consent.usPrivacyIabConsentString_mock = "US Privacy String"
    let body = generateBody()
    let user = body[NSString.userKey] as? [String: AnyHashable]
    XCTAssertEqual(user?[NSString.uspIabKey]!, "US Privacy String")
  }

  func testBodyWithCriteoPrivacyOpIn() {
    consent.usPrivacyCriteoState = .optIn
    let body = generateBody()
    let user = body[NSString.userKey] as? [String: AnyHashable]
    XCTAssertEqual(user?[NSString.uspCriteoOptout], false)
  }

  func testBodyWithCriteoPrivacyOpOut() {
    consent.usPrivacyCriteoState = .optOut
    let body = generateBody()
    let user = body[NSString.userKey] as? [String: AnyHashable]
    XCTAssertEqual(user?[NSString.uspCriteoOptout], true)
  }

  func testBodyWithContext() {
    context = CRContextData(dictionary: ["a.a": "foo", "b": "bar"])
    let expected = ["a": ["a": "foo"], "b": "bar"] as [String: AnyHashable]
    let body = generateBody()
    let publisher = body["publisher"] as? [String: AnyHashable]
    XCTAssertEqual(publisher?["ext"], expected)
  }

  func testBodyWithChildDirectedTreatment() {

    var body: [String: AnyHashable]
    var regsDictionary: [String: AnyHashable]
    var childDirectedTreatmentFromBody: NSNumber

    // case nil - undefined
    childDirectedTreatment = nil
    body = generateBody()
    XCTAssertFalse(body.keys.contains(CR_ApiQueryKeys.regs))

    // case false
    childDirectedTreatment = NSNumber(value: false)
    body = generateBody()
    XCTAssertTrue(body.keys.contains(CR_ApiQueryKeys.regs))
    do {
      regsDictionary = try XCTUnwrap(body[CR_ApiQueryKeys.regs] as? [String: AnyHashable])
      childDirectedTreatmentFromBody = try XCTUnwrap(
        regsDictionary[CR_ApiQueryKeys.coppa] as? NSNumber)
      XCTAssertFalse(childDirectedTreatmentFromBody.boolValue)
    } catch {
      XCTFail("Test failed for childDirectedTreatment with value false!")
    }

    // case true
    childDirectedTreatment = NSNumber(value: true)
    body = generateBody()
    XCTAssertTrue(body.keys.contains(CR_ApiQueryKeys.regs))
    do {
      regsDictionary = try XCTUnwrap(body[CR_ApiQueryKeys.regs] as? [String: AnyHashable])
      childDirectedTreatmentFromBody = try XCTUnwrap(
        regsDictionary[CR_ApiQueryKeys.coppa] as? NSNumber)
      XCTAssertTrue(childDirectedTreatmentFromBody.boolValue)
    } catch {
      XCTFail("Test failed for childDirectedTreatment with value true!")
    }
  }

  private func generateBody() -> [String: AnyHashable] {
    let body = serializer.body(
      with: request, consent: consent, config: config, deviceInfo: deviceInfo, context: context,
      childDirectedTreatment: childDirectedTreatment)
    return body as? [String: AnyHashable] ?? [:]
  }
}

class CR_GdprSerializerMock: CR_GdprSerializer {

  var dictionaryValue: [String: NSObject]? = .some(["key": "value" as NSObject])

  open override func dictionary(for gdpr: CR_Gdpr) -> [String: NSObject]? {
    return dictionaryValue
  }
}

class CR_InternalContextProviderMock: CR_InternalContextProvider {
  open override func fetchInternalUserContext() -> [String: Any] {
    [:]
  }
}
