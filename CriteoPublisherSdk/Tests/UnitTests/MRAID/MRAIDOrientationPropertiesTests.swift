//
//  MRAIDOrientationPropertiesTests.swift
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

final class MRAIDOrientationPropertiesTests: XCTestCase {
    var logger: MRAIDLoggerMock!
    var urlOpener: URLOpenerMock!
    var messageHandler: MRAIDMessageHandler!
    var urlHandler: MRAIDURLHandler!
    var logHandler: MRAIDLogHandler!
    var messageMockListener: MockMessageDelegate!

    override func setUpWithError() throws {
        logger = MRAIDLoggerMock()
        urlOpener = URLOpenerMock(openBlock: nil)
        urlHandler = CRMRAIDURLHandler(with: logger, urlOpener: urlOpener)
        logHandler = MRAIDLogHandler(criteoLogger: logger)
        messageHandler = MRAIDMessageHandler(logHandler: logHandler, urlHandler: urlHandler)
        messageMockListener = MockMessageDelegate()
        messageHandler.delegate = messageMockListener
    }

    override func tearDownWithError() throws {
        logger = nil
        urlOpener = nil
        urlHandler = nil
        messageHandler = nil
        logHandler = nil
        messageMockListener = nil
    }

    func testOrientationMaskMapper() {
        XCTAssertEqual(MRAIDOrientationProperties.orientationMask(for: .landscape), [.landscape])
        XCTAssertEqual(MRAIDOrientationProperties.orientationMask(for: .portrait), [.portrait])
        XCTAssertEqual(MRAIDOrientationProperties.orientationMask(for: .none), [.all])
    }

    func testOrientationPropertiesAction() throws {
        let expectation = XCTestExpectation(description: "orientation properties update action is executed")
        messageMockListener.orientationPropertiesBlock = { orientaions in
            guard
                orientaions.action == Action.orientationPropertiesUpdate,
                orientaions.allowOrientationChange == true,
                orientaions.forceOrientation == .landscape
            else { return }
            expectation.fulfill()
        }
        messageHandler.handle(
            message: [
                "action": Action.orientationPropertiesUpdate.rawValue,
                "allow_orientation_change": true,
                "force_orientation": "landscape"
            ] as [String: Any])
        wait(for: [expectation], timeout: 0.1)
    }

    func testOrientationPropertiesDecoder() throws {
        let decoder = MRAIDJSONDecoder()
        let json = try XCTUnwrap("""
        {
            "action": "orientation_properties_update",
            "allow_orientation_change": true,
            "force_orientation": "landscape"
        }
        """.data(using: .utf8))

        let orientationProperties = try XCTUnwrap(try? decoder.decode(MRAIDOrientationPropertiesMessage.self, from: json))
        XCTAssertEqual(orientationProperties.action, Action.orientationPropertiesUpdate)
        XCTAssertEqual(orientationProperties.allowOrientationChange, true)
        XCTAssertEqual(orientationProperties.forceOrientation, .landscape)
    }
}
