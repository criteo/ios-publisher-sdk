//
//  MRAIDResizeContainerView.swift
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

import UIKit
import WebKit

final class MRAIDResizeContainerView: UIView {
    private enum Constants {
        static let closeAreaHeight: CGFloat = 50
        static let closeAreaWidth: CGFloat = 50
    }

    private let resizeMessage: MRAIDResizeMessage
    private let webView: WKWebView
    private let closeAreaView: UIView
    private weak var webViewBannerContainer: UIView?
    private let delegate: MRAIDResizeHandlerDelegate

    public init(with resizeMessage: MRAIDResizeMessage, webView: WKWebView, delegate: MRAIDResizeHandlerDelegate) throws {
        self.resizeMessage = resizeMessage
        self.webView = webView
        self.closeAreaView = UIView()
        self.delegate = delegate
        super.init(frame: .zero)

        setup()
    }

    deinit {
        debugPrint(#function)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func show(webView: WKWebView, with resizeMessage: MRAIDResizeMessage, delegate: MRAIDResizeHandlerDelegate) throws {
        guard let containerView = webView.cr_rootViewController()?.view else { throw MRAIDResizeHandler.ResizeError.missingParentViewReference }
        let resizeView = try MRAIDResizeContainerView(with: resizeMessage, webView: webView, delegate: delegate)

        containerView.addSubview(resizeView)
        NSLayoutConstraint.activate([
            resizeView.heightAnchor.constraint(equalToConstant: CGFloat(resizeMessage.height)),
            resizeView.widthAnchor.constraint(equalToConstant: CGFloat(resizeMessage.width)),
            resizeView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: CGFloat(resizeMessage.offsetY)),
            resizeView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: CGFloat(resizeMessage.offsetX))
        ])
    }
}

/// MARK: - Private methods
private extension MRAIDResizeContainerView {
    func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        webViewBannerContainer = webView.superview
        /// remove from current container
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.removeAllConstraints()
        webView.removeFromSuperview()
        /// add it to new container and set new constraints
        addSubview(webView)
        NSLayoutConstraint.activate([
          webView.widthAnchor.constraint(equalTo: widthAnchor),
          webView.heightAnchor.constraint(equalTo: heightAnchor),
          webView.centerXAnchor.constraint(equalTo: centerXAnchor),
          webView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        /// setup the close button area
        initCloseAreaView()
    }

    func initCloseAreaView() {
        addSubview(closeAreaView)
        closeAreaView.backgroundColor = .red
        closeAreaView.translatesAutoresizingMaskIntoConstraints = false
        /// set the dimension of the close area
        NSLayoutConstraint.activate([
            closeAreaView.heightAnchor.constraint(equalToConstant: Constants.closeAreaHeight),
            closeAreaView.widthAnchor.constraint(equalToConstant: Constants.closeAreaWidth)
        ])
        /// set the position according to custom close position
        switch resizeMessage.customClosePosition {
        case .topLeft: NSLayoutConstraint.activate([
            closeAreaView.leadingAnchor.constraint(equalTo: leadingAnchor),
            closeAreaView.topAnchor.constraint(equalTo: topAnchor)
        ])
        case .topRight: NSLayoutConstraint.activate([
            closeAreaView.trailingAnchor.constraint(equalTo: trailingAnchor),
            closeAreaView.topAnchor.constraint(equalTo: topAnchor)
        ])
        case .center: NSLayoutConstraint.activate([
            closeAreaView.centerXAnchor.constraint(equalTo: centerXAnchor),
            closeAreaView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        case .bottomLeft: NSLayoutConstraint.activate([
            closeAreaView.leadingAnchor.constraint(equalTo: leadingAnchor),
            closeAreaView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        case .bottomRight: NSLayoutConstraint.activate([
            closeAreaView.trailingAnchor.constraint(equalTo: trailingAnchor),
            closeAreaView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        case .topCenter: NSLayoutConstraint.activate([
            closeAreaView.centerXAnchor.constraint(equalTo: centerXAnchor),
            closeAreaView.topAnchor.constraint(equalTo: topAnchor)
        ])
        case .bottomCenter: NSLayoutConstraint.activate([
            closeAreaView.centerXAnchor.constraint(equalTo: centerXAnchor),
            closeAreaView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        }
        /// setup the tap recognizer
        closeAreaView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))
    }

    @objc
    func close() {
        /// remove from current container
        guard let container = webViewBannerContainer else { return }
        webView.removeAllConstraints()
        webView.removeFromSuperview()
        /// add webView back to banner container
        container.addSubview(webView)
        webView.fill(in: container)
        /// remove resized container from parent view and notify mraid handler about close completion
        delegate.didCloseResizedAdView()
        removeFromSuperview()
    }
}
