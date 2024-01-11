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

public protocol MRAIDResizeHandlerDelegate {
    func didCloseResizedAdView()
}

public class MRAIDResizeHandler {

    enum ResizeError: Error {
        case missingParentViewReference
        case exceedingMaxSize
        case exceedingMinSize
        case closeAreaOutOfBounds
    }

    public enum Constants {
        public static let minHeight: CGFloat = 50
        public static let minWidth: CGFloat = 50
    }

    private let webView: WKWebView
    private let delegate: MRAIDResizeHandlerDelegate
    private var resizedContainer: UIView?

    init(webView: WKWebView, delegate: MRAIDResizeHandlerDelegate) {
        self.webView = webView
        self.delegate = delegate
    }

    public func canResize(mraidState: MRAIDState) -> Bool {
        guard mraidState == .default || mraidState == .resized else { return false }
        return true
    }

    public func resize(with resizeMessage: MRAIDResizeMessage, webViewContainer: UIView?) throws {
        guard
            let rootViewController = webView.cr_rootViewController(),
            let topView = rootViewController.view else {
            throw ResizeError.missingParentViewReference
        }

        let containerSize = topView.frame.size
        let positionInContainer = webView.convert(webView.frame.origin, to: topView)
        let autoRotate = rootViewController.shouldAutorotate

        try verifyMinSize(message: resizeMessage)
        let container = resizedContainer
        if resizeMessage.allowOffscreen {
            let updatedResizeMessage = try verifyCloseAreaOutOfBounds(containerSize: containerSize, positionInContainer: positionInContainer, message: resizeMessage, autoRotate: autoRotate)
            resizedContainer = try MRAIDResizeContainerView.show(webView: webView,
                                              with: updatedResizeMessage,
                                              delegate: delegate,
                                              webViewContainer: webViewContainer)
        } else {
            let updatedResizeMessage = try updateResizeMessageToFit(containerSize: containerSize, positionInContainer: positionInContainer, with: resizeMessage)
            resizedContainer = try MRAIDResizeContainerView.show(webView: webView,
                                              with: updatedResizeMessage,
                                              delegate: delegate,
                                              webViewContainer: webViewContainer)
        }

        if let previousContainer = container {
            previousContainer.removeFromSuperview()
        }
    }

    public func updateResizeMessageToFit(containerSize: CGSize, positionInContainer: CGPoint, with message: MRAIDResizeMessage) throws -> MRAIDResizeMessage {
        let containerHeight = Int(containerSize.height)
        let containerWidth = Int(containerSize.width)

        /// verify if the new size exceeds the container size
        /// ignore autoRotate because we cannot fix all position issues. in case it doesn't the container in one orientation then the ad will be partially off screen.
        if message.height > containerHeight || message.width > containerWidth {
            throw ResizeError.exceedingMaxSize
        }

        /// position of the resized ad container in the container (top view)
        let adjustedPosition = CGPoint(x: positionInContainer.x + CGFloat(message.offsetX), y: positionInContainer.y + CGFloat(message.offsetY))
        let adContainerPosition = CGPoint(x: adjustedPosition.x < 0 ? 0 : adjustedPosition.x, y: adjustedPosition.y < 0 ? 0 : adjustedPosition.y )

        var positionX = Int(adContainerPosition.x)
        var positionY = Int(adContainerPosition.y)

        if positionX + message.width > containerWidth {
            /// try to adjust offset x in order to fit the ad into container
            positionX -= (positionX + message.width - containerWidth)
        }

        if positionY + message.height > containerHeight {
            positionY -= (positionY + message.height - containerHeight)
        }

        return .init(action: message.action,
                     width: message.width,
                     height: message.height,
                     offsetX: positionX,
                     offsetY: positionY,
                     customClosePosition: message.customClosePosition,
                     allowOffscreen: message.allowOffscreen)
    }

    public func verifyCloseAreaOutOfBounds(containerSize: CGSize, positionInContainer: CGPoint, message: MRAIDResizeMessage, autoRotate: Bool) throws -> MRAIDResizeMessage {
        let adjustedPosition = CGPoint(x: positionInContainer.x + CGFloat(message.offsetX), y: positionInContainer.y + CGFloat(message.offsetY))
        let embededCloseAreaPosition = closeAreaPositionInAdContainer(with: .init(width: message.width, height: message.height), for: message.customClosePosition)

        let caTopLeftCorner: CGPoint = CGPoint(x: embededCloseAreaPosition.x + adjustedPosition.x, y: embededCloseAreaPosition.y + adjustedPosition.y)
        let caTopRightCorner: CGPoint = .init(x: caTopLeftCorner.x + CGFloat(Constants.minWidth), y: caTopLeftCorner.y)
        let caBottomLeftCorner: CGPoint = .init(x: caTopLeftCorner.x, y: caTopLeftCorner.y + CGFloat(Constants.minHeight))
        let caBottomRightCorner: CGPoint = .init(x: caTopRightCorner.x, y: caTopRightCorner.y + CGFloat(Constants.minHeight))

        let bounds = CGRect(origin: .zero, size: containerSize)
        let closeAreaCorners: [CGPoint] = [caTopLeftCorner, caTopRightCorner, caBottomLeftCorner, caBottomRightCorner]

        /// verify that all corners of the close are view are in the container's frame
        guard bounds.contains(points: closeAreaCorners) else {
            throw ResizeError.closeAreaOutOfBounds
        }

        /// verify that all corners of the close are are in the container's frame when orientation changes
        let rotatedBounds = CGRect(origin: .zero, size: .init(width: containerSize.height, height: containerSize.width))
        guard autoRotate, rotatedBounds.contains(points: closeAreaCorners) else {
            throw ResizeError.closeAreaOutOfBounds
        }

        return .init(action: message.action,
                     width: message.width,
                     height: message.height,
                     offsetX: Int(adjustedPosition.x),
                     offsetY: Int(adjustedPosition.y),
                     customClosePosition: message.customClosePosition,
                     allowOffscreen: message.allowOffscreen)
    }

    public func verifyMinSize(message: MRAIDResizeMessage) throws {
        guard
            message.height >= Int(Constants.minWidth),
            message.width >= Int(Constants.minWidth) else {
            throw ResizeError.exceedingMinSize
        }
    }

    public func closeAreaPositionInAdContainer(with newSize: CGSize, for customClosePosition: MRAIDCustomClosePosition) -> CGPoint {
        switch customClosePosition {
        case .topLeft: return .init(x: 0,
                                    y: 0)
        case .topRight: return .init(x: newSize.width - Constants.minWidth,
                                     y: 0)
        case .center: return .init(x: newSize.width / 2 - Constants.minWidth / 2,
                                   y: newSize.height / 2 - Constants.minHeight / 2)
        case .bottomLeft: return .init(x: 0,
                                       y: newSize.height - Constants.minHeight)
        case .bottomRight: return .init(x: newSize.width - Constants.minWidth,
                                        y: newSize.height - Constants.minHeight)
        case .topCenter: return .init(x: newSize.width / 2 - Constants.minWidth / 2,
                                      y: 0)
        case .bottomCenter: return .init(x: newSize.width / 2 - Constants.minWidth / 2,
                                         y: newSize.height - Constants.minHeight)
        }
    }

    public func close() {
        guard let closeable = resizedContainer as? MRAIDClosableView else { return }
        closeable.closeView()
    }
}
