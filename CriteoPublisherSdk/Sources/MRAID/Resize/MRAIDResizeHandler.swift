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
        guard let rootViewController = webView.cr_rootViewController(), let topView = rootViewController.view else { throw ResizeError.missingParentViewReference }
        guard resizeMessage.height >= Constants.minWidth, resizeMessage.width >= Constants.minWidth else { throw ResizeError.exceedingMinSize }
        if !resizeMessage.allowOffscreen, (resizeMessage.height > Int(topView.frame.size.height) || resizeMessage.width > Int(topView.frame.size.width)) {
            throw ResizeError.exceedingMaxSize
        }

        try MRAIDResizeContainerView.show(webView: webView, with: resizeMessage, delegate: delegate)
    }
}
