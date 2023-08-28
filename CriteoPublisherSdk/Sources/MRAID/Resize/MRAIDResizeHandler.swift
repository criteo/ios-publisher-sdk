//
//  MRAIDResizeHandler.swift
//  CriteoPublisherSdk
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

import Foundation
import WebKit

protocol MRAIDResizeHandlerDelegate {
    func didCloseResizedAdView()
}

struct MRAIDResizeHandler {

    enum ResizeError: Error {
        case missingParentViewReference
        case exceedingMaxSize
        case exceedingMinSize
        case closeAreaOutOfBounds
    }

    private enum Constants {
        static let minHeight: Int = 50
        static let minWidth: Int = 50
    }

    let webView: WKWebView
    let resizeMessage: MRAIDResizeMessage
    let mraidState: MRAIDState

    func canResize() -> Bool {
        guard mraidState == .default || mraidState == .resized else { return false }

        return true
    }

    func resize(delegate: MRAIDResizeHandlerDelegate) throws {
        guard
            let rootViewController = webView.cr_rootViewController(),
            let topView = rootViewController.view else {
            throw ResizeError.missingParentViewReference
        }

        try verifyMinSize(message: resizeMessage)
        try verifyOutOfTheBounds(container: topView.frame.size,
                                 message: resizeMessage,
                                 autoRotate: rootViewController.shouldAutorotate)
        try MRAIDResizeContainerView.show(webView: webView, with: resizeMessage, delegate: delegate)
    }
}

// MARK: - Private methods
private extension MRAIDResizeHandler {
    func verifyMinSize(message: MRAIDResizeMessage) throws {
        guard
            resizeMessage.height >= Constants.minWidth,
            resizeMessage.width >= Constants.minWidth else {
            throw ResizeError.exceedingMinSize
        }
    }

    func verifyOutOfTheBounds(container size: CGSize, message: MRAIDResizeMessage, autoRotate: Bool) throws {
        let containerHeight = Int(size.height)
        let containerWidth = Int(size.width)

        if message.allowOffscreen {
            try verifyCloseAreaOutOfBounds(container: size,
                                           message: message,
                                           autoRotate: autoRotate)
        } else if autoRotate {
            /// In case orientation change is supported check if the height doesn't exceed the width as well (same for width).
            if
                message.height > containerHeight ||
                message.height > containerWidth ||
                message.width > containerWidth ||
                message.width > containerHeight {
                    throw ResizeError.exceedingMaxSize
                }
        } else if message.height > containerHeight || message.width > containerWidth {
            throw ResizeError.exceedingMaxSize
        }
    }

    func verifyCloseAreaOutOfBounds(container size: CGSize, message: MRAIDResizeMessage, autoRotate: Bool) throws {
        func rectContains(corners: [CGPoint], rect: CGRect) -> Bool {
            return corners.filter({ !rect.contains($0)}).isEmpty
        }

        let caPosition = closeAreaPosition(for: message)
        let caTopLeftCorner: CGPoint = .init(x: caPosition.x + CGFloat(message.offsetX), y: caPosition.y + CGFloat(message.offsetY))
        let caTopRightCorner: CGPoint = .init(x: caTopLeftCorner.x + CGFloat(Constants.minWidth), y: caTopLeftCorner.y)
        let caBottomLeftCorner: CGPoint = .init(x: caTopLeftCorner.x, y: caTopLeftCorner.y + CGFloat(Constants.minHeight))
        let caBottomRightCorner: CGPoint = .init(x: caTopRightCorner.x, y: caTopRightCorner.y + CGFloat(Constants.minHeight))

        let bounds = CGRect(origin: .zero, size: size)
        let closeAreaCorners: [CGPoint] = [caTopLeftCorner, caTopRightCorner, caBottomLeftCorner, caBottomRightCorner]

        /// verify that all corners of the close are view are in the container's frame
        guard rectContains(corners: closeAreaCorners, rect: bounds) else {
            throw ResizeError.closeAreaOutOfBounds
        }

        /// verify that all corners of the close are are in the container's frame when orientation changes
        guard autoRotate, rectContains(corners: closeAreaCorners, rect: .init(origin: .zero, size: .init(width: size.height, height: size.width))) else {
            throw ResizeError.closeAreaOutOfBounds
        }
    }

    func closeAreaPosition(for resizeMessage: MRAIDResizeMessage) -> CGPoint {
        switch resizeMessage.customClosePosition {
        case .topLeft: return .init(x: 0,
                                    y: 0)
        case .topRight: return .init(x: resizeMessage.offsetX - Constants.minWidth,
                                     y: 0)
        case .center: return .init(x: resizeMessage.width / 2 - Constants.minWidth / 2,
                                   y: resizeMessage.height / 2 - Constants.minHeight / 2)
        case .bottomLeft: return .init(x: 0,
                                       y: resizeMessage.height - Constants.minHeight)
        case .bottomRight: return .init(x: resizeMessage.width - Constants.minWidth,
                                        y: resizeMessage.height - Constants.minHeight)
        case .topCenter: return .init(x: resizeMessage.width / 2 - Constants.minWidth / 2,
                                      y: 0)
        case .bottomCenter: return .init(x: resizeMessage.width / 2 - Constants.minWidth / 2,
                                         y: resizeMessage.height - Constants.minHeight)
        }
    }
}
