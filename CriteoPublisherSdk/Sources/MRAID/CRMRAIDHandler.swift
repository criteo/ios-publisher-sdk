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
import AVKit

public typealias VoidCompletion = () -> Void

private struct CRMRAIDHandlerConstants {
    static let viewabilityRefreshTime: Double = 0.2
}

@objc
public class CRMRAIDHandler: NSObject {
    
    private enum Constants {
        static let updateDelay: CGFloat = 0.05
        static let scriptHandlerName = "criteoMraidBridge"
    }

    private let webView: WKWebView
    private var timer: Timer?
    private var isViewVisible: Bool = false
    private var messageHandler: MRAIDMessageHandler
    private weak var delegate: CRMRAIDHandlerDelegate?
    private var state: MRAIDState = .loading
    private let logger: CRMRAIDLogger
    private static let updateDelay: CGFloat = 0.05
    private var mraidBundle: Bundle? = CRMRAIDUtils.mraidResourceBundle()
    private let placementType: CRPlacementType
    private var orientationProperties: MRAIDOrientationProperties?

    @objc
    public init(
        placementType: CRPlacementType,
        webView: WKWebView,
        criteoLogger: CRMRAIDLogger,
        urlOpener: CRExternalURLOpener,
        delegate: CRMRAIDHandlerDelegate?
    ) {
        self.placementType = placementType
        self.logger = criteoLogger
        self.webView = webView
        self.messageHandler = MRAIDMessageHandler(
            logHandler: MRAIDLogHandler(criteoLogger: criteoLogger),
            urlHandler: CRMRAIDURLHandler(with: criteoLogger, urlOpener: urlOpener))
        super.init()
        self.delegate = delegate
        self.messageHandler.delegate = self
        
        DispatchQueue.main.async {
            self.webView.configuration.userContentController.add(self, name: "criteoMraidBridge")
        }
    }
    
  @objc
  public func send(error: String, action: String) {
    evaluate(javascript: "window.mraid.notifyError(\"\(error)\",\"\(action)\");")
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
    onDealloc()
  }

  @objc
  public func canLoadAd() -> Bool {
    return state != .expanded
  }

  @objc
  public func isExpanded() -> Bool {
    return state == .expanded
  }


  @objc
  public func inject(into html: String) -> String {
    return CRMRAIDUtils.build(html: html, from: mraidBundle)
  }


    @objc
    public func onAdLoad() {
        state = .default
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.setDefaultSupportedOrientationMask()
            self.setMaxSize()
            self.setScreen(size: UIScreen.main.bounds.size)
            self.setCurrentPosition()
            self.setSupportedFeatures()
            self.sendReadyEvent(with: self.placementType.placementTypeString)
        }
        startViabilityNotifier()
        registerDeviceOrientationListener()
    }


    @objc
    public func onSuccessClose() {
        setCurrentPosition()
        notifyClosed()
        /// default state is set to default only if the ad is in expanded or resized state otherwise set it to hidden.
        state = (state == .expanded || state == .resized) ? .default : .hidden
    }


    @objc
    public func injectMRAID() {
        guard let mraid = CRMRAIDUtils.loadMraid(from: mraidBundle) else {
            logger.mraidLog(error: "could not load mraid")
            return
        }

        let mraidScript = WKUserScript(
            source: mraid, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        DispatchQueue.main.async { [weak self] in
            self?.webView.configuration.userContentController.addUserScript(mraidScript)
        }
    }

    @objc
    public func updateMraid(bundle: Bundle?) {
        mraidBundle = bundle
    }

    @objc
    public func setCurrentPosition() {
        guard let parentView = webView.cr_parentViewController()?.view else {
            logger.mraidLog(error: "Could not get the parent view reference")
            return
        }

        let origin = webView.bounds.origin
        let size = webView.bounds.size
        let position = parentView.convert(origin, from: webView)
        setCurrent(position: CGRect(origin: position, size: size))
    }

    @objc
    public func setScreen(size: CGSize) {
        evaluate(javascript: "window.mraid.setScreenSize(\(size.width),\(size.height));")
    }

    @objc
    public func shouldAdAutoRotate() -> Bool {
        guard let orientationProperties = self.orientationProperties else { return true }
        return orientationProperties.allowOrientationChange
    }

    @objc
      public func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
          guard let orientationProperties = self.orientationProperties else { return .all }
          return orientationProperties.supportedOrietationMask
      }

    @objc
    public func onDealloc() {
        stopViabilityNotifier()
        unregisterDeviceOrientationListener()
        webView.configuration.userContentController.removeScriptMessageHandler(forName: Constants.scriptHandlerName)
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
fileprivate extension CRMRAIDHandler {
    func setOrientationProperties(from viewController: UIViewController) {
        orientationProperties = MRAIDOrientationProperties(allowOrientationChange: viewController.shouldAutorotate,
                                                           orientationMask: viewController.supportedInterfaceOrientations)
    }

    func setDefaultSupportedOrientationMask() {
        /// Avoid overriding the already set orientation properties
        guard orientationProperties == nil else { return }

        switch placementType {
        case .banner:
            guard let viewController = webView.cr_rootViewController() else { return }
            setOrientationProperties(from: viewController)
        case .interstitial:
            guard
                let interstitialViewController = webView.cr_parentViewController(),
                let viewController = interstitialViewController.presentingViewController else {
                break
            }
            setOrientationProperties(from: viewController)
        }
    }

    func stopViabilityNotifier() {
        timer?.invalidate()
        timer = nil
    }

    func setMaxSize() {
        let size: CGSize =
        webView.cr_parentViewController()?.view.bounds.size ?? UIScreen.main.bounds.size
        evaluate(
            javascript:
                "window.mraid.setMaxSize(\(size.width), \(size.height), \(UIScreen.main.scale));")
    }

    @objc func setIsViewable(visible: Bool) {
        evaluate(javascript: "window.mraid.setIsViewable(\"\(visible.stringValue)\");")
    }

    @objc func viewabilityCheck() {
        let isWebViewVisible = webView.isVisibleToUser
        guard isWebViewVisible != isViewVisible else { return }

        isViewVisible = isWebViewVisible
        setIsViewable(visible: isWebViewVisible)
    }

    func sendReadyEvent(with placement: String) {
        evaluate(javascript: "window.mraid.notifyReady(\"\(placement)\");")
    }

    func setCurrent(position: CGRect) {
        evaluate(
            javascript:
                "window.mraid.setCurrentPosition(\(position.minX),\(position.minY),\(position.width),\(position.height));"
        )
    }

    func setSupportedFeatures() {
        guard
            let data = try? JSONEncoder().encode(MRAIDFeatures()),
            let supportedFeaturesString = String(data: data, encoding: .utf8) else {
            logger.mraidLog(error: "Could not set supported features")
            return
        }
        evaluate(javascript: "window.mraid.setSupports(\(supportedFeaturesString));")
    }

    func evaluate(javascript: String) {
        webView.evaluateJavaScript(javascript, completionHandler: handleJSCallback)
    }

    func handleJSCallback(_ agent: Any?, _ error: Error?) {
        if let error = error {
            debugPrint("error on js call: \(error)")
        } else {
            debugPrint("no error on js callback")
        }
    }

    func notifyExpanded() {
        evaluate(javascript: "window.mraid.notifyExpanded();")
    }

    func notifyClosed() {
        evaluate(javascript: "window.mraid.notifyClosed();")
    }

    func notifyResized() {
        evaluate(javascript: "window.mraid.notifyResized();")
    }

    func registerDeviceOrientationListener() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(deviceOrientationDidChange),
            name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    @objc func deviceOrientationDidChange() {
        setCurrentPosition()
        setMaxSize()
        setScreen(size: UIScreen.main.bounds.size)
    }

    func unregisterDeviceOrientationListener() {
        NotificationCenter.default.removeObserver(
            self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
}

// MARK: - MRAID Message delegate
extension CRMRAIDHandler: MRAIDMessageHandlerDelegate {
    public func didReceive(expand action: MRAIDExpandMessage) {
        guard state != .expanded else { return }

        delegate?.expand?(width: action.width, height: action.width, url: action.url) { [weak self] in
            self?.onSuccessClose()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + CRMRAIDHandler.updateDelay) {
            self.state = .expanded
            self.setCurrentPosition()
            self.notifyExpanded()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.onSetOrientation()
        }
    }

    func onSetOrientation() {
        if #available(iOS 16.0, *) {
            if let window = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                window.requestGeometryUpdate(.iOS(interfaceOrientations: orientationProperties?.orientationMask ?? .all))
            } else if let parentViewController = webView.cr_parentViewController() {
                parentViewController.setNeedsUpdateOfSupportedInterfaceOrientations()
            }
        } else if let interfaceOrientation = orientationProperties?.orientationMask {
            UIDevice.current.setValue(interfaceOrientation.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }

    public func didReceiveCloseAction() {
        guard state == .default || state == .expanded else {
            logger.mraidLog(error: "Close action is not valid in current state: \(state)")
            return
        }

        delegate?.close { [weak self] in
            self?.onSuccessClose()
        }
    }

    public func didReceivePlayVideoAction(with url: String) {
        guard
            let parentViewController = webView.cr_rootViewController(),
            let videoURL = URL(string: url)
        else {
            logger.mraidLog(error: "Could not play video with url: \(url)")
            return
        }

        let playerViewController = AVPlayerViewController()
        playerViewController.player = AVPlayer(url: videoURL)

        parentViewController.present(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
    }

    public func didReceive(resize action: MRAIDResizeMessage) {
        guard placementType == .banner else {
            logger.mraidLog(error: "Resize action can be execute only for banner ad type")
            return

        }

        let resizeHandler = MRAIDResizeHandler(webView: webView, resizeMessage: action, mraidState: state)
        guard resizeHandler.canResize() else {
            logger.mraidLog(error: "Resize action can be execute only on default or resized states")
            return
        }

        do {
            try resizeHandler.resize(delegate: self)
            state = .resized
            notifyResized()
        } catch {
            logger.mraidLog(error: "Could not resize ad.")
        }
    }

    public func didReceive(orientation properties: MRAIDOrientationPropertiesMessage) {
        orientationProperties = MRAIDOrientationProperties(allowOrientationChange: properties.allowOrientationChange,
                                                           forceOrientation: properties.forceOrientation)
        guard placementType == .interstitial || state == .expanded else { return }
        onSetOrientation()
    }
}

extension CRMRAIDHandler: MRAIDResizeHandlerDelegate {
    func didCloseResizedAdView() {
        onSuccessClose()
    }
}
