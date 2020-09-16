//
//  CR_GdprSerializerTests.swift
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

class CR_GdprSerializerTests: XCTestCase {

  var gdpr: CR_GdprMock = CR_GdprMock()
  var serializer: CR_GdprSerializer = CR_GdprSerializer()

  func testNoGdpr() {
    self.gdpr.configure(tcfVersion: .versionUnknown)

    let actual = self.serializer.dictionary(for: self.gdpr)

    XCTAssertNil(actual)
  }

  func testGdprTcf1() {
    self.gdpr.configure(tcfVersion: .version1_1)
    let expected: [String: AnyHashable]? = [
      NSString.gdprVersionKey: 1,
      NSString.gdprConsentDataKey: NSString.gdprConsentStringForTcf1_1,
      NSString.gdprAppliesKey: true,
    ]

    let actual = self.serializer.dictionary(for: self.gdpr)

    XCTAssertEqual(actual, expected)

  }

  func testGdprTcf2() {
    self.gdpr.configure(tcfVersion: .version2_0)
    let expected: [String: AnyHashable]? = [
      NSString.gdprVersionKey: 2,
      NSString.gdprConsentDataKey: NSString.gdprConsentStringForTcf2_0,
      NSString.gdprAppliesKey: true,
    ]

    let actual = self.serializer.dictionary(for: self.gdpr)

    XCTAssertEqual(actual, expected)
  }

  func testNoConsentString() {
    self.gdpr.configure(tcfVersion: .version2_0)
    self.gdpr.consentStringValue = nil
    let expected: [String: AnyHashable]? = [
      NSString.gdprVersionKey: 2,
      NSString.gdprAppliesKey: true,
        // No NSString.gdprConsentDataKey
    ]

    let actual = self.serializer.dictionary(for: self.gdpr)

    XCTAssertEqual(actual, expected)
  }

  func testNoGdprApplies() {
    self.gdpr.configure(tcfVersion: .version2_0)
    self.gdpr.appliesValue = nil
    let expected: [String: AnyHashable]? = [
      NSString.gdprVersionKey: 2,
      NSString.gdprConsentDataKey: NSString.gdprConsentStringForTcf2_0,
      // No NSString.gdprAppliesKey
    ]

    let actual = self.serializer.dictionary(for: self.gdpr)

    XCTAssertEqual(actual, expected)
  }
}
