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
    private let offsetX = 10
    private let offsetY = 10
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
        let containerSize = CGSize(width: containerWidth, height: containerHeight)
        let handler = try XCTUnwrap(resizeHandler)
        let topLeftPosition = handler.closeAreaPositionInAdContainer(with: containerSize, for: .topLeft)
        let topRightPosition = handler.closeAreaPositionInAdContainer(with: containerSize, for: .topRight)
        let centerPosition = handler.closeAreaPositionInAdContainer(with: containerSize, for: .center)
        let bottomLeftPosition = handler.closeAreaPositionInAdContainer(with: containerSize, for: .bottomLeft)
        let bottomRightPosition = handler.closeAreaPositionInAdContainer(with: containerSize, for: .bottomRight)
        let topCenterPosition = handler.closeAreaPositionInAdContainer(with: containerSize, for: .topCenter)
        let bottomCenterPosition = handler.closeAreaPositionInAdContainer(with: containerSize, for: .bottomCenter)

        let minWidth = Int(MRAIDResizeHandler.Constants.minWidth)
        let minHeight = Int(MRAIDResizeHandler.Constants.minHeight)
        XCTAssertEqual(topLeftPosition, .init(x: 0, y: 0))
        XCTAssertEqual(topRightPosition, .init(x: containerWidth - minWidth, y: 0))
        XCTAssertEqual(centerPosition, .init(x: containerWidth / 2 - minWidth / 2, y: containerHeight / 2 - minHeight / 2))
        XCTAssertEqual(bottomLeftPosition, .init(x: 0, y: containerHeight - minHeight))
        XCTAssertEqual(bottomRightPosition, .init(x: containerWidth - minWidth, y: containerHeight - minHeight))
        XCTAssertEqual(topCenterPosition, .init(x: containerWidth / 2 - minWidth / 2, y: 0))
        XCTAssertEqual(bottomCenterPosition, .init(x: containerWidth / 2 - minWidth / 2, y: containerHeight - minHeight))
    }

    func testCloseAreaOutOfBounds() throws {
        let handler = try XCTUnwrap(resizeHandler)
        let containerSize = CGSize(width: containerWidth, height: containerHeight)
        let positionInContainer: CGPoint = .init(x: 60, y: 0)

        let outOfBoundsResizeMessage = MRAIDResizeMessage(action: .resize,
                                               width: containerWidth,
                                               height: containerHeight,
                                               offsetX: offsetX,
                                               offsetY: offsetY,
                                               customClosePosition: .topRight,
                                               allowOffscreen: true)
        XCTAssertNil(try? handler.verifyCloseAreaOutOfBounds(containerSize: containerSize,
                                                             positionInContainer: positionInContainer,
                                                             message: outOfBoundsResizeMessage,
                                                             autoRotate: true))

        
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
