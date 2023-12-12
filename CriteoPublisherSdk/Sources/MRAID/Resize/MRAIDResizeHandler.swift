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

    public enum Constants {
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
        let offset = try verifyOutOfTheBounds(container: topView.frame.size,
                                 message: resizeMessage,
                                 autoRotate: rootViewController.shouldAutorotate)

        let updatedResizeMessage = MRAIDResizeMessage(action: resizeMessage.action,
                                                      width: resizeMessage.width,
                                                      height: resizeMessage.height,
                                                      offsetX: Int(offset.width), offsetY: Int(offset.height),
                                                      customClosePosition: resizeMessage.customClosePosition,
                                                      allowOffscreen: resizeMessage.allowOffscreen)
        try MRAIDResizeContainerView.show(webView: webView, with: updatedResizeMessage, delegate: delegate)
    }

    func verifyMinSize(message: MRAIDResizeMessage) throws {
        guard
            resizeMessage.height >= Constants.minWidth,
            resizeMessage.width >= Constants.minWidth else {
            throw ResizeError.exceedingMinSize
        }
    }

    func verifyOutOfTheBounds(container size: CGSize, message: MRAIDResizeMessage, autoRotate: Bool) throws -> CGSize {
        let containerHeight = Int(size.height)
        let containerWidth = Int(size.width)

        if message.allowOffscreen {
            try verifyCloseAreaOutOfBounds(container: size,
                                           message: message,
                                           autoRotate: autoRotate)
            return .init(width: message.offsetX, height: message.offsetY)

        } else {
            /// verify if the new size exceeds the container size
            /// ignore autoRotate because we cannot fix all position issues. in case it doesn't the container in one orientation then the ad will be partially off screen.
            if message.height > containerHeight || message.width > containerWidth {
                throw ResizeError.exceedingMaxSize
            }

            /// verify if the new position doesn't set the ad container off screen, in case it does then adjust the offset values.
            var offsetX = message.offsetX < 0 ? 0 : message.offsetX
            var offsetY = message.offsetY < 0 ? 0 : message.offsetY

            if offsetX + message.width > containerWidth {
                offsetX = offsetX - (offsetX + message.width - containerWidth)
            }

            if offsetY + message.height > containerHeight {
                offsetY = offsetY - (offsetY + message.height - containerHeight)
            }

            return .init(width: offsetX, height: offsetY)
        }
    }

    func verifyCloseAreaOutOfBounds(container size: CGSize, message: MRAIDResizeMessage, autoRotate: Bool) throws {
        let caTopLeftCorner: CGPoint = closeAreaPosition(for: message)
        let caTopRightCorner: CGPoint = .init(x: caTopLeftCorner.x + CGFloat(Constants.minWidth), y: caTopLeftCorner.y)
        let caBottomLeftCorner: CGPoint = .init(x: caTopLeftCorner.x, y: caTopLeftCorner.y + CGFloat(Constants.minHeight))
        let caBottomRightCorner: CGPoint = .init(x: caTopRightCorner.x, y: caTopRightCorner.y + CGFloat(Constants.minHeight))

        let bounds = CGRect(origin: .zero, size: size)
        let closeAreaCorners: [CGPoint] = [caTopLeftCorner, caTopRightCorner, caBottomLeftCorner, caBottomRightCorner]

        /// verify that all corners of the close are view are in the container's frame
        guard bounds.contains(points: closeAreaCorners) else {
            throw ResizeError.closeAreaOutOfBounds
        }

        /// verify that all corners of the close are are in the container's frame when orientation changes
        let rotatedBounds = CGRect(origin: .zero, size: .init(width: size.height, height: size.width))
        guard autoRotate, rotatedBounds.contains(points: closeAreaCorners) else {
            throw ResizeError.closeAreaOutOfBounds
        }
    }

    func closeAreaPosition(for resizeMessage: MRAIDResizeMessage) -> CGPoint {
        let embededCloseAreaPosition = closeAreaPositionInAdContainer(for: resizeMessage.customClosePosition)
        return CGPoint(x: embededCloseAreaPosition.x + CGFloat(resizeMessage.offsetX), y: embededCloseAreaPosition.y + CGFloat(resizeMessage.offsetY))
    }

    func closeAreaPositionInAdContainer(for customClosePosition: MRAIDCustomClosePosition) -> CGPoint {
        switch customClosePosition {
        case .topLeft: return .init(x: 0,
                                    y: 0)
        case .topRight: return .init(x: resizeMessage.width - Constants.minWidth,
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
