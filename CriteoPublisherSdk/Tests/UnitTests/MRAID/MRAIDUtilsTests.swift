//
//  MRAIDUtilsTests.swift
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2023 Criteo. All rights reserved.
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

final class MRAIDUtilsTests: XCTestCase {
    func testMRAIDBundle() {
        let mraidBundle = CR_MRAIDUtils.mraidBundle()
        XCTAssertNotNil(mraidBundle)
        XCTAssert(mraidBundle!.bundlePath.contains("CriteoMRAIDResource.bundle"))
    }

    func testMraidInjectScript() {
        let mraidBundle = CR_MRAIDUtils.mraidBundle()
        let mraidString = CRMRAIDUtils.loadMraid(from: mraidBundle)
        let html = CRMRAIDUtils.build(html: "<html><head></head><body></body></html>", from: mraidBundle)
        XCTAssertTrue(html.contains(mraidString!))
    }

    func testMRAIDLoad() {
        let mraidBundle = CR_MRAIDUtils.mraidBundle()
        let mraidString = CRMRAIDUtils.loadMraid(from: mraidBundle)
        XCTAssertNotNil(mraidString)
    }
}
