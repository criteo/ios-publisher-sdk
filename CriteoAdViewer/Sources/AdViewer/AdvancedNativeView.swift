//
//  AdvancedNativeView.swift
//  CriteoAdViewer
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
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

class AdvancedNativeView: UIView {
  public weak var delegate: CRNativeLoaderDelegate?
  private var loader: CRNativeLoader!
  private var adView: CRVNativeAdView!

  convenience init(adUnit: CRNativeAdUnit, criteo: Criteo) {
    self.init(frame: CGRect(origin: CGPoint(), size: CGSize()))
    loader = CRNativeLoader(adUnit: adUnit, criteo: criteo)!
    loader.delegate = self
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    xibSetup()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    xibSetup()
  }

  public func loadAd() {
    loader.loadAd()
  }
}

extension AdvancedNativeView: CRNativeLoaderDelegate {
  public func nativeLoader(_ loader: CRNativeLoader, didReceive ad: CRNativeAd) {
    delegate?.nativeLoader?(loader, didReceive: ad)
    adView!.nativeLoader(loader, didReceive: ad)
  }

  public func nativeLoader(_ loader: CRNativeLoader, didFailToReceiveAdWithError error: Error) {
    delegate?.nativeLoader?(loader, didFailToReceiveAdWithError: error)
  }

  public func nativeLoaderDidDetectClick(_ loader: CRNativeLoader) {
    delegate?.nativeLoaderDidDetectClick?(loader)
  }

  public func nativeLoaderDidDetectImpression(_ loader: CRNativeLoader) {
    delegate?.nativeLoaderDidDetectImpression?(loader)
  }

  public func nativeLoaderWillLeaveApplication(_ loader: CRNativeLoader) {
    delegate?.nativeLoaderWillLeaveApplication?(loader)
  }
}

extension AdvancedNativeView {
  fileprivate func xibSetup() {
    adView = loadNib(nibName: "CRVNativeAdView") as? CRVNativeAdView
    bounds = adView.bounds
    addSubview(adView)
    adView.translatesAutoresizingMaskIntoConstraints = false
    addConstraints(
      NSLayoutConstraint.constraints(
        withVisualFormat: "H:|[childView]|",
        options: [], metrics: nil, views: ["childView": adView as Any]))
    addConstraints(
      NSLayoutConstraint.constraints(
        withVisualFormat: "V:|[childView]|",
        options: [], metrics: nil, views: ["childView": adView as Any]))
  }
}

extension UIView {
  /** Loads instance from nib with the same name. */
  func loadNib() -> UIView? {
    let nibName = type(of: self).description().components(separatedBy: ".").last!
    return loadNib(nibName: nibName)
  }

  /** Loads instance from nib with specified nibName. */
  func loadNib(nibName: String) -> UIView? {
    let bundle = Bundle(for: type(of: self))
    let nib = UINib(nibName: nibName, bundle: bundle)
    return nib.instantiate(withOwner: self, options: nil).first as? UIView
  }
}
