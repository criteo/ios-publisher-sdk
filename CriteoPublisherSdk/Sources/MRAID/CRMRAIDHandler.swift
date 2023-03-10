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

private struct CRMRAIDHandlerConstants {
  static let viewabilityRefreshTime: Double = 0.2
}

@objc
public class CRMRAIDHandler: NSObject {
  private let webView: WKWebView
  private var timer: Timer?
  private var isViewVisible: Bool = false
  private let messageHandler: MRAIDMessageHandler

  @objc
  public init(with webView: WKWebView, criteoLogger: CRMRAIDLogger) {
    self.webView = webView
    self.messageHandler = MRAIDMessageHandler(
      logHandler: MRAIDLogHandler(criteoLogger: criteoLogger))
    super.init()
    self.webView.configuration.userContentController.add(self, name: "criteoMraidBridge")
  }

  @objc
  public func onAdLoad(with placementType: String) {
    sendReadyEvent(with: placementType)
    startViabilityNotifier()
  }

  @objc
  public func send(error: String, action: String) {
    let js = "window.mraid.notifyError(\"\(error)\",\"\(action)\");"
    webView.evaluateJavaScript(js, completionHandler: handleJSCallback)
  }

  @objc
  public func setIsViewable(visible: Bool) {
    let js = "window.mraid.setIsViewable(\"\(visible.stringValue)\");"
    webView.evaluateJavaScript(js, completionHandler: handleJSCallback)
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

  @objc
  public func stopViabilityNotifier() {
    timer?.invalidate()
    timer = nil
  }

  deinit {
    stopViabilityNotifier()
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
  fileprivate func sendReadyEvent(with placement: String) {
    let js = "window.mraid.notifyReady(\"\(placement)\");"
    webView.evaluateJavaScript(js, completionHandler: handleJSCallback)
  }

  fileprivate func handleJSCallback(_ agent: Any?, _ error: Error?) {
    debugPrint("error on js call: \(error.debugDescription)")
  }

  @objc
  fileprivate func viewabilityCheck() {
    let isWebViewVisible = webView.isVisibleToUser
    guard isWebViewVisible != isViewVisible else { return }

    isViewVisible = isWebViewVisible
    setIsViewable(visible: isWebViewVisible)
  }
}
