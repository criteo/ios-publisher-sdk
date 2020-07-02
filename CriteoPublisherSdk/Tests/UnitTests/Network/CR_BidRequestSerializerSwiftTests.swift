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

    var config: CR_Config = CR_Config()
    var consent: CR_DataProtectionConsentMock = CR_DataProtectionConsentMock()
    var deviceInfo: CR_DeviceInfoMock = CR_DeviceInfoMock()

    override func setUp() {
        gdprSerializer = CR_GdprSerializerMock()
        serializer = CR_BidRequestSerializer(gdprSerializer: gdprSerializer)
        request = CR_CdbRequest(adUnits: [
            CR_CacheAdUnit(adUnitId: "1", width: 1, height: 1),
            CR_CacheAdUnit(adUnitId: "2", width: 2, height: 2)
        ])
        config.criteoPublisherId = "Test Published Id"
    }

    func testUrl() {
        let expected = URL(string:"https://bidder.criteo.com/inapp/v2?profileId=235")

        let url = serializer.url(with: config)

        XCTAssertEqual(url, expected)
    }

    func testBodyWithSdkVersion() {
        let body = generateBody()

        let sdkVersion = body[NSString.sdkVersionKey]! as! String
        XCTAssertEqual(sdkVersion, config.sdkVersion)
    }

    func testBodyWithProfileId() {
        let body = generateBody()

        let profileId = body[NSString.profileIdKey]! as! NSNumber
        XCTAssertEqual(profileId, config.profileId)
    }

    func testBodyWithPublisher() {
        let expected = [
            NSString.bundleIdKey: config.appId,
            NSString.cpIdKey: config.criteoPublisherId!,
        ]

        let body = generateBody()

        let publisher: [String: AnyHashable] = body[NSString.publisherKey]! as! [String: AnyHashable]
        XCTAssertEqual(publisher, expected)
    }

    // MARK: User in body

    func testBodyWithUser() {
        let body = generateBody()

        let user: [String: AnyHashable] = body[NSString.userKey]! as! [String: AnyHashable]
        XCTAssertEqual(user.count, 6)
        XCTAssertEqual(user[NSString.userAgentKey], deviceInfo.userAgent)
        XCTAssertEqual(user[NSString.deviceIdKey], deviceInfo.deviceId)
        XCTAssertEqual(user[NSString.deviceOsKey], config.deviceOs)
        XCTAssertEqual(user[NSString.deviceModelKey], config.deviceModel)
        XCTAssertEqual(user[NSString.deviceIdTypeKey], NSString.deviceIdTypeValue)
        XCTAssertEqual(user[NSString.uspIabKey], consent.usPrivacyIabConsentString!)
    }

    func testBodyWithUsPrivacyConsentString() {
        consent.usPrivacyIabConsentString_mock = "US Privacy String"

        let body = generateBody()

        let user: [String: AnyHashable] = body[NSString.userKey]! as! [String: AnyHashable]
        XCTAssertEqual(user[NSString.uspIabKey]!, "US Privacy String")
    }

    func testBodyWithCriteoPrivacyOpIn() {
        consent.usPrivacyCriteoState = .optIn

        let body = generateBody()

        let user: [String: AnyHashable] = body[NSString.userKey]! as! [String: AnyHashable]
        XCTAssertEqual(user[NSString.uspCriteoOptout]!, false)
    }

    func testBodyWithCriteoPrivacyOpOut() {
        consent.usPrivacyCriteoState = .optOut

        let body = generateBody()

        let user: [String: AnyHashable] = body[NSString.userKey]! as! [String: AnyHashable]
        XCTAssertEqual(user[NSString.uspCriteoOptout]!, true)
    }

    func testBodyWithMopubConsent() {
        consent.mopubConsent = "Privacy consent for mopub"

        let body = generateBody()

        let user: [String: AnyHashable] = body[NSString.userKey]! as! [String: AnyHashable]
        XCTAssertEqual(user[NSString.mopubConsent]!, "Privacy consent for mopub")
    }

    private func generateBody() -> [String: AnyHashable] {
        return serializer.body(with: request,
                               consent: consent,
                               config: config,
                               deviceInfo: deviceInfo) as! [String: AnyHashable]
    }
}

class CR_GdprSerializerMock : CR_GdprSerializer {

    var dictionaryValue: [String : NSObject]? = .some([ "key": "value" as NSObject ])

    open override func dictionary(for gdpr: CR_Gdpr) -> [String : NSObject]? {
        return dictionaryValue
    }
}
