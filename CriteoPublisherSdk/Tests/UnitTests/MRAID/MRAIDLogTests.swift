//
//  MRAIDLogTests.swift
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
import CriteoPublisherSdk

final class MRAIDLogTests: XCTestCase {
    func testMRAIDLogDecode() {
        do {
            let dataString = "{\"action\":\"log\",\"message\":\"test\",\"logLevel\":\"Debug\",\"logId\":\"12\"}".data(using: .utf8)
            XCTAssertNotNil(dataString)
            let log = try JSONDecoder().decode(MRAIDLog.self, from: dataString!)
            XCTAssertEqual(log.action, Action.log)
            XCTAssertEqual(log.message, "test")
            XCTAssertEqual(log.logLevel, LogLevel.debug)
            XCTAssertEqual(log.logId, "12")
        } catch {
            XCTFail("couldn't decode mraid log")
        }
    }

    func testMRAIDLogMessageDecode() {
        do {
            let expandMessage = "{\"action\":\"expand\"}".data(using: .utf8)
            XCTAssertNotNil(expandMessage)
            let expand = try JSONDecoder().decode(MRAIDActionMessage.self, from: expandMessage!)
            XCTAssertEqual(expand.action, Action.expand)

            let openMessage = "{\"action\":\"open\"}".data(using: .utf8)
            XCTAssertNotNil(openMessage)
            let open = try JSONDecoder().decode(MRAIDActionMessage.self, from: openMessage!)
            XCTAssertEqual(open.action, Action.open)

            let closeMessage = "{\"action\":\"close\"}".data(using: .utf8)
            XCTAssertNotNil(closeMessage)
            let close = try JSONDecoder().decode(MRAIDActionMessage.self, from: closeMessage!)
            XCTAssertEqual(close.action, Action.close)
        } catch {
            XCTFail("couldn't decode mraid message action")
        }
    }
}
