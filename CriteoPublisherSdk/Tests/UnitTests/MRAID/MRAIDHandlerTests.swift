//
//  MRAIDHandlerTests.swift
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

import CriteoPublisherSdk
import WebKit
import XCTest

class MockMessageDelegate: MRAIDMessageHandlerDelegate {
    typealias ExpandBlock = (Int, Int, URL?) -> Void
    typealias CloseBlock = () -> Void
    typealias OrientationPropertiesBlock = (MRAIDOrientationPropertiesMessage) -> Void

    var expandBlock: ExpandBlock?
    var closeBlock: CloseBlock?
    var orientationPropertiesBlock: OrientationPropertiesBlock?

    func didReceive(expand action: MRAIDExpandMessage) {
        expandBlock?(action.width, action.height, action.url)
    }

    func didReceiveCloseAction() {
        closeBlock?()
    }

    func didReceivePlayVideoAction(with url: String) {
        debugPrint("play video from url: \(url)")
    }

    func didReceive(resize action: MRAIDResizeMessage) {
        debugPrint(#function)
    }

    func didReceive(orientation properties: MRAIDOrientationPropertiesMessage) {
        orientationPropertiesBlock?(properties)
    }
}

final class MRAIDHandlerTests: XCTestCase {
    var logger: MRAIDLoggerMock!
    var urlOpener: URLOpenerMock!
    var messageHandler: MRAIDMessageHandler!
    var urlHandler: MRAIDURLHandler!
    var logHandler: MRAIDLogHandler!
    var messageMockListener: MockMessageDelegate!

    override func setUp() {
        logger = MRAIDLoggerMock()
        urlOpener = URLOpenerMock(openBlock: nil)
        urlHandler = CRMRAIDURLHandler(with: logger, urlOpener: urlOpener)
        logHandler = MRAIDLogHandler(criteoLogger: logger)
        messageHandler = MRAIDMessageHandler(logHandler: logHandler, urlHandler: urlHandler)
        messageMockListener = MockMessageDelegate()
    }

    override func tearDown() {
        logger = nil
        urlOpener = nil
        urlHandler = nil
        messageHandler = nil
        logHandler = nil
        messageMockListener = nil
    }

    func testOpenAction() {
        let urlString = "https://criteo.com"
        let expectation = XCTestExpectation(description: "url to match")
        urlOpener.openBlock = { url in
            if url.absoluteString == urlString {
                expectation.fulfill()
            }
        }
        messageHandler.handle(message: [
            "action": Action.open.rawValue,
            "url": urlString
        ])

        wait(for: [expectation], timeout: 0.1)
    }

    func testExpandAction() {
        let urlString = "https://criteo.com"
        messageHandler.delegate = messageMockListener
        let expectation = XCTestExpectation(description: "expand action to be received with all data")
        messageMockListener.expandBlock = { width, height, url in
            if width == 200, height == 100, url?.absoluteString == urlString {
                expectation.fulfill()
            }
        }

        messageHandler.handle(
            message: [
                "action": Action.expand.rawValue,
                "width": 200,
                "height": 100,
                "url": urlString
            ] as [String: Any])

        wait(for: [expectation], timeout: 0.1)
    }

    func testCloseAction() {
        let expectation = XCTestExpectation(description: "close action is received")
        messageMockListener.closeBlock = {
            expectation.fulfill()
        }

        messageHandler.delegate = messageMockListener
        messageHandler.handle(message: [
            "action": Action.close.rawValue
        ])

        wait(for: [expectation], timeout: 0.1)
    }
}
