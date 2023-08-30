//
//  MRAIDResizeTests.swift
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
import WebKit
@testable import CriteoPublisherSdk

final class MockMRAIDResizeHandlerDelegate: MRAIDResizeHandlerDelegate {
    func didCloseResizedAdView() {
        debugPrint(#function)
    }
}

final class MRAIDResizeTests: XCTestCase {
    private var resizeHandler: MRAIDResizeHandler?
    private var resizeMessage: MRAIDResizeMessage?
    private let containerWidth = 100
    private let containerHeight = 100
    private let offsetX = 130
    private let offsetY = 45
    private var webView: WKWebView?
    private var viewController: UIViewController?

    override func setUpWithError() throws {
       try super.setUpWithError()

        resizeMessage = MRAIDResizeMessage(action: .resize,
                                               width: containerWidth,
                                               height: containerHeight,
                                               offsetX: offsetX,
                                               offsetY: offsetY,
                                               customClosePosition: .bottomCenter,
                                               allowOffscreen: true)

        webView = WKWebView()
        viewController = UIViewController()
        viewController?.view.addSubview(webView!)
        resizeHandler = MRAIDResizeHandler(webView: webView!,
                                           resizeMessage: resizeMessage!,
                                           mraidState: .default)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        resizeMessage = nil
        resizeHandler = nil
        viewController = nil
        webView = nil
    }


    func testCloseAreaPositionInAdContainer() throws {
        let topLeftPosition = try XCTUnwrap(resizeHandler?.closeAreaPositionInAdContainer(for: .topLeft))
        let topRightPosition = try XCTUnwrap(resizeHandler?.closeAreaPositionInAdContainer(for: .topRight))
        let centerPosition = try XCTUnwrap(resizeHandler?.closeAreaPositionInAdContainer(for: .center))
        let bottomLeftPosition = try XCTUnwrap(resizeHandler?.closeAreaPositionInAdContainer(for: .bottomLeft))
        let bottomRightPosition = try XCTUnwrap(resizeHandler?.closeAreaPositionInAdContainer(for: .bottomRight))
        let topCenterPosition = try XCTUnwrap(resizeHandler?.closeAreaPositionInAdContainer(for: .topCenter))
        let bottomCenterPosition = try XCTUnwrap(resizeHandler?.closeAreaPositionInAdContainer(for: .bottomCenter))

        XCTAssertEqual(topLeftPosition, .init(x: 0, y: 0))
        XCTAssertEqual(topRightPosition, .init(x: containerWidth - MRAIDResizeHandler.Constants.minWidth, y: 0))
        XCTAssertEqual(centerPosition, .init(x: containerWidth / 2 - MRAIDResizeHandler.Constants.minWidth / 2, y: containerHeight / 2 - MRAIDResizeHandler.Constants.minHeight / 2))
        XCTAssertEqual(bottomLeftPosition, .init(x: 0, y: containerHeight - MRAIDResizeHandler.Constants.minHeight))
        XCTAssertEqual(bottomRightPosition, .init(x: containerWidth - MRAIDResizeHandler.Constants.minWidth, y: containerHeight - MRAIDResizeHandler.Constants.minHeight))
        XCTAssertEqual(topCenterPosition, .init(x: containerWidth / 2 - MRAIDResizeHandler.Constants.minWidth / 2, y: 0))
        XCTAssertEqual(bottomCenterPosition, .init(x: containerWidth / 2 - MRAIDResizeHandler.Constants.minWidth / 2, y: containerHeight - MRAIDResizeHandler.Constants.minHeight))
    }

    func testCloseAreaPositionOnTopView() throws {
        let bottomCenterPosition = try XCTUnwrap(resizeHandler?.closeAreaPosition(for: resizeMessage!))
        XCTAssertEqual(bottomCenterPosition, .init(x: containerWidth / 2 - MRAIDResizeHandler.Constants.minWidth / 2 + offsetX, y: containerHeight - MRAIDResizeHandler.Constants.minHeight + offsetY))
    }

    func testResizeState() {
        /// ad can resize only in default or resized state
        XCTAssertTrue(try XCTUnwrap(resizeHandler?.canResize()))
        resizeHandler = MRAIDResizeHandler(webView: WKWebView(),
                                           resizeMessage: resizeMessage!,
                                           mraidState: .resized)
        XCTAssertTrue(try XCTUnwrap(resizeHandler?.canResize()))

        resizeHandler = MRAIDResizeHandler(webView: WKWebView(),
                                           resizeMessage: resizeMessage!,
                                           mraidState: .expanded)
        XCTAssertFalse(try XCTUnwrap(resizeHandler?.canResize()))
        resizeHandler = MRAIDResizeHandler(webView: WKWebView(),
                                           resizeMessage: resizeMessage!,
                                           mraidState: .loading)
        XCTAssertFalse(try XCTUnwrap(resizeHandler?.canResize()))
        resizeHandler = MRAIDResizeHandler(webView: WKWebView(),
                                           resizeMessage: resizeMessage!,
                                           mraidState: .hidden)
        XCTAssertFalse(try XCTUnwrap(resizeHandler?.canResize()))
    }

    func testTopView() {
        do {
            try resizeHandler?.resize(delegate: MockMRAIDResizeHandlerDelegate())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testMinSize(for resizeMessage: MRAIDResizeMessage) throws {
        resizeHandler = MRAIDResizeHandler(webView: webView!,
                                           resizeMessage: resizeMessage,
                                           mraidState: .default)
        do {
            try resizeHandler?.resize(delegate: MockMRAIDResizeHandlerDelegate())
            XCTFail("Resize shouldn't be possible if the width or hight are below min values")
        } catch {
            let resizeErro = try XCTUnwrap(error as? MRAIDResizeHandler.ResizeError)
            XCTAssertEqual(resizeErro, MRAIDResizeHandler.ResizeError.exceedingMinSize)
        }
    }

    func testMinSize() throws {
        resizeMessage = MRAIDResizeMessage(action: .resize,
                                               width: 49,
                                               height: 100,
                                               offsetX: offsetX,
                                               offsetY: offsetY,
                                               customClosePosition: .topLeft,
                                               allowOffscreen: true)
        try testMinSize(for: resizeMessage!)

        resizeMessage = MRAIDResizeMessage(action: .resize,
                                               width: 50,
                                               height: -1,
                                               offsetX: offsetX,
                                               offsetY: offsetY,
                                               customClosePosition: .topLeft,
                                               allowOffscreen: true)

        try testMinSize(for: resizeMessage! )
    }
}
