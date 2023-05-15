//
//  CRFulllScreenContainer.swift
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

public protocol CRFulllScreenContainerDelegate: AnyObject {
  func didExitFullScreen(webView: WKWebView)
}

@objc
public class CRFulllScreenContainer: UIViewController {
  let closeButton: UIButton
  let webView: WKWebView
  let webViewSize: CGSize
  weak var delegate: CRFulllScreenContainerDelegate?
  private weak var webViewBannerContainer: UIView?
  private var dismissCompletion: VoidCompletion?

  @objc
  public init(with webView: WKWebView, size: CGSize, dismissCompletion: VoidCompletion?) {
    self.closeButton = UIButton(type: .custom)
    self.webView = webView
    self.webViewSize = size
    self.dismissCompletion = dismissCompletion
    super.init(nibName: nil, bundle: nil)

    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc
  public func close(with completion: VoidCompletion?) {
    // 1. remove webview from container
    guard let container = webViewBannerContainer else { return }
    closeButton.isHidden = true
    webView.removeConstraints(webView.constraints)
    webView.removeFromSuperview()
    // 2. add webview back to banner container
    container.addSubview(webView)
    NSLayoutConstraint.activate([
      webView.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 1),
      webView.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1),
      webView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
      webView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
    ])
    // 3. dismiss full screen controller
    dismiss(animated: true, completion: completion)
  }
}

// MARK: - Private methods
extension CRFulllScreenContainer {
  @objc
  fileprivate func onCloseButtonPressed() {
    close(with: dismissCompletion)
  }

  fileprivate func initCloseButton() {
    closeButton.addTarget(self, action: #selector(onCloseButtonPressed), for: .touchUpInside)
    let bounds = CGRect(x: 10, y: 10, width: 25, height: 25)
    closeButton.layer.addSublayer(circleLayer(in: bounds))
    closeButton.layer.addSublayer(xLayerInBounds(in: bounds))
  }

  fileprivate func circleLayer(in bounds: CGRect) -> CAShapeLayer {
    let layer = CAShapeLayer()
    let path = UIBezierPath.init(ovalIn: bounds)
    layer.path = path.cgPath
    layer.fillColor = UIColor.black.cgColor
    layer.strokeColor = UIColor.white.cgColor
    layer.lineWidth = 1.0
    return layer
  }

  fileprivate func xLayerInBounds(in bounds: CGRect) -> CAShapeLayer {
    let layer = CAShapeLayer()
    let xPos = UIBezierPath()
    let gap: CGFloat = 0.3 * bounds.size.width
    xPos.move(
      to: CGPoint(
        x: bounds.origin.x + (bounds.size.width - gap),
        y: bounds.origin.y + (bounds.size.height - gap)))
    xPos.addLine(
      to: CGPoint(
        x: bounds.origin.x + gap,
        y: bounds.origin.y + gap))
    xPos.move(
      to: CGPoint(
        x: bounds.origin.x + gap,
        y: bounds.origin.y + bounds.size.height - gap))
    xPos.addLine(
      to: CGPoint(
        x: bounds.origin.x + (bounds.size.width - gap),
        y: bounds.origin.y + gap))
    layer.path = xPos.cgPath
    layer.strokeColor = UIColor.white.cgColor
    layer.lineWidth = 1.0
    return layer
  }

  fileprivate func applySafeAreaConstraints(to closeButton: UIButton) {
    closeButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      closeButton.widthAnchor.constraint(equalToConstant: 45),
      closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor, multiplier: 1)
    ])
    // set the close button on the top right corner of the screen in case webview size exceed screen size
    // if not then set the close button on the top right corner of the webview
    let targetView = referenceViewForCloseButton(for: webViewSize)
    // set the close button on the top right corner of the view
    NSLayoutConstraint.activate([
      closeButton.topAnchor.constraint(equalTo: targetView.safeAreaLayoutGuide.topAnchor),
      closeButton.trailingAnchor.constraint(equalTo: targetView.safeAreaLayoutGuide.trailingAnchor)
    ])
  }

  fileprivate func applyConstraints(to webView: UIView, width: CGFloat, height: CGFloat) {

    webView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      webView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      webView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])

    if width > 0 {
      NSLayoutConstraint.activate([
        webView.widthAnchor.constraint(equalToConstant: width)
      ])
    } else {
      NSLayoutConstraint.activate([
        webView.widthAnchor.constraint(equalTo: view.widthAnchor)
      ])
    }

    if height > 0 {
      NSLayoutConstraint.activate([
        webView.heightAnchor.constraint(equalToConstant: height)
      ])
    } else {
      NSLayoutConstraint.activate([
        webView.heightAnchor.constraint(equalTo: view.heightAnchor)
      ])
    }
  }

  fileprivate func setup() {
    addBlurBackgroundEffect()
    // 1. get the reference to the current container.
    webViewBannerContainer = webView.superview
    // 2. remove all constraints
    webView.removeFromSuperview()
    // 3. add webview to new container
    view.addSubview(webView)
    view.addSubview(closeButton)
    // 4. init close button
    initCloseButton()
    applySafeAreaConstraints(to: closeButton)
    // 5. setup webview constraints
    applyConstraints(to: webView, width: webViewSize.width, height: webViewSize.height)
  }

  fileprivate func addBlurBackgroundEffect() {
    view.backgroundColor = .clear
    let blurEffect = UIBlurEffect(style: .dark)
    let blurredEffectView = UIVisualEffectView(effect: blurEffect)
    blurredEffectView.frame = view.bounds
    view.addSubview(blurredEffectView)
  }

  fileprivate func referenceViewForCloseButton(for size: CGSize) -> UIView {
    return (view.frame.width < size.width || view.frame.height < webViewSize.height)
      ? view : webView
  }
}
