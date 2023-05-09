//
//  CRMRAIDHandler.swift
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

public typealias VoidCompletion = () -> Void

private struct CRMRAIDHandlerConstants {
  static let viewabilityRefreshTime: Double = 0.2
}

@objc
public protocol CRMRAIDHandlerDelegate: AnyObject {
  @objc
  optional
    func expand(width: Int, height: Int, url: URL?, completion: VoidCompletion?)
  func close(completion: VoidCompletion?)
}

@objc
public class CRMRAIDHandler: NSObject {
  private let webView: WKWebView
  private var timer: Timer?
  private var isViewVisible: Bool = false
  private var messageHandler: MRAIDMessageHandler
  private weak var delegate: CRMRAIDHandlerDelegate?
  private var state: MRAIDState = .loading

  @objc
  public init(
    with webView: WKWebView,
    criteoLogger: CRMRAIDLogger,
    urlOpener: CRExternalURLOpener,
    delegate: CRMRAIDHandlerDelegate?
  ) {
    self.webView = webView
    self.messageHandler = MRAIDMessageHandler(
      logHandler: MRAIDLogHandler(criteoLogger: criteoLogger),
      urlHandler: CRMRAIDURLHandler(with: criteoLogger, urlOpener: urlOpener))
    super.init()
    self.delegate = delegate
    self.messageHandler.delegate = self
    self.webView.configuration.userContentController.add(self, name: "criteoMraidBridge")
  }

  @objc
  public func onAdLoad(with placementType: String) {
    state = .default
    setMax(size: UIScreen.main.bounds.size)
    sendReadyEvent(with: placementType)
    startViabilityNotifier()
    registerDeviceOrientationListener()
  }

  @objc
  public func send(error: String, action: String) {
    evaluate(js: "window.mraid.notifyError(\"\(error)\",\"\(action)\");")
  }

  @objc
  public func startViabilityNotifier() {
    timer = Timer.scheduledTimer(
      timeInterval: CRMRAIDHandlerConstants.viewabilityRefreshTime,
      target: self,
      selector: #selector(viewabilityCheck),
      userInfo: nil,
      repeats: true)
    timer?.fire()
  }

  deinit {
    stopViabilityNotifier()
    unregisterDeviceOrientationListener()
  }

  @objc
  public func canLoadAd() -> Bool {
    return state == .loading
  }

  @objc
  public func isExpanded() -> Bool {
    return state == .expanded
  }

  @objc
  public func onSuccessClose() {
    notifyClosed()
    state = state == .expanded ? .default : .hidden
  }

  @objc
  public func inject(into html: String) -> String {
    return CRMRAIDUtils.build(html: html, from: CRMRAIDUtils.mraidResourceBundle())
  }
}

// MARK: - JS message handler
extension CRMRAIDHandler: WKScriptMessageHandler {
  public func userContentController(
    _ userContentController: WKUserContentController,
    didReceive message: WKScriptMessage
  ) {
    messageHandler.handle(message: message.body)
  }
}

// MARK: - Private methods
extension CRMRAIDHandler {

  fileprivate func stopViabilityNotifier() {
    timer?.invalidate()
    timer = nil
  }

  fileprivate func setMax(size: CGSize) {
    evaluate(js: "window.mraid.setMaxSize(\(size.width), \(size.height), \(UIScreen.main.scale));")
  }

  @objc fileprivate func setIsViewable(visible: Bool) {
    evaluate(js: "window.mraid.setIsViewable(\"\(visible.stringValue)\");")
  }

  @objc fileprivate func viewabilityCheck() {
    let isWebViewVisible = webView.isVisibleToUser
    guard isWebViewVisible != isViewVisible else { return }

    isViewVisible = isWebViewVisible
    setIsViewable(visible: isWebViewVisible)
  }

  fileprivate func sendReadyEvent(with placement: String) {
    evaluate(js: "window.mraid.notifyReady(\"\(placement)\");")
  }

  fileprivate func setCurrent(position: CGRect) {
    evaluate(
      js:
        "window.mraid.setCurrentPosition({x:\(position.minX), y:\(position.minY), width:\(position.width), height:\(position.height)});"
    )
  }

  fileprivate func evaluate(js: String) {
    webView.evaluateJavaScript(js, completionHandler: handleJSCallback)
  }

  fileprivate func handleJSCallback(_ agent: Any?, _ error: Error?) {
    if let error = error {
      debugPrint("error on js call: \(error)")
    } else {
      debugPrint("no error on js callback")
    }
  }

  fileprivate func notifyExpanded() {
    evaluate(js: "window.mraid.notifyExpanded();")
  }

  fileprivate func notifyClosed() {
    evaluate(js: "window.mraid.notifyClosed();")
  }

  fileprivate func registerDeviceOrientationListener() {
    NotificationCenter.default.addObserver(
      self, selector: #selector(deviceOrientationDidChange),
      name: UIDevice.orientationDidChangeNotification, object: nil)
  }

  @objc fileprivate func deviceOrientationDidChange() {
    setMax(size: UIScreen.main.bounds.size)
  }

  fileprivate func unregisterDeviceOrientationListener() {
    NotificationCenter.default.removeObserver(
      self, name: UIDevice.orientationDidChangeNotification, object: nil)
  }
}

// MARK: - MRAID Message delegate
extension CRMRAIDHandler: MRAIDMessageHandlerDelegate {
  public func didReceive(expand action: MRAIDExpandMessage) {
    debugPrint(#function)
    guard state != .expanded else { return }

    //        delegate?.expand(width: action.width, height: action.width, url: action.url) { [weak self] in
    delegate?.expand?(width: 300, height: 200, url: action.url) { [weak self] in
      self?.onSuccessClose()
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
      self.state = .expanded
      self.notifyExpanded()
    }
  }

  public func didReceiveCloseAction() {
    guard state == .default || state == .expanded else {
      // notify error
      return
    }

    delegate?.close { [weak self] in
      self?.onSuccessClose()
    }
  }
}
