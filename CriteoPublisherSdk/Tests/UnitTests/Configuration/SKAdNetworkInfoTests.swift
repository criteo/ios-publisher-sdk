//
//  SKAdNetworkInfoTests.swift
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

@testable import CriteoPublisherSdk

class SKAdNetworkInfoTests: XCTestCase {
  let validInfo = SKAdNetworkInfo(testBundle: "skanValid")
  let invalidInfo = SKAdNetworkInfo(testBundle: "skanInvalid")

  func testGivenValidBundleThenAdNetworkIdsProvided() throws {
    XCTAssertEqual(
      validInfo.adNetworkIds,
      ["hs6bdukanm.skadnetwork", "whateverid.skadnetwork"]
    )
  }

  func testGivenInvalidBundleThenAdNetworkIdsIsEmpty() throws {
    XCTAssertTrue(invalidInfo.adNetworkIds.isEmpty)
  }

  func testGivenValidBundleWithCriteoIdThenHasCriteoId() throws {
    XCTAssertTrue(validInfo.hasCriteoId)
  }

  func testGivenInvalidBundleWithoutCriteoIdThenHasNotCriteoId() throws {
    XCTAssertFalse(invalidInfo.hasCriteoId)
  }
}

extension SKAdNetworkInfo {
  init(testBundle: String) {
    let bundlePath = Bundle.main.resourcePath!
    let bundle = Bundle(path: "\(bundlePath)/\(testBundle).bundle")!
    self.init(bundle: bundle)
  }
}
