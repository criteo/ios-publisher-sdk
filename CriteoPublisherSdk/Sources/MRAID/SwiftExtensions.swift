//
//  SwiftExtensions.swift
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

extension UIView {
  public var isVisibleToUser: Bool {

    if isHidden || alpha == 0 || superview == nil {
      return false
    }

    guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
      return false
    }

    let viewFrame = convert(bounds, to: rootViewController.view)

    let topSafeArea: CGFloat
    let bottomSafeArea: CGFloat

    if #available(iOS 11.0, *) {
      topSafeArea = rootViewController.view.safeAreaInsets.top
      bottomSafeArea = rootViewController.view.safeAreaInsets.bottom
    } else {
      topSafeArea = rootViewController.topLayoutGuide.length
      bottomSafeArea = rootViewController.bottomLayoutGuide.length
    }

    return viewFrame.minX >= 0 && viewFrame.maxX <= rootViewController.view.bounds.width
      && viewFrame.minY >= topSafeArea
      && viewFrame.maxY <= rootViewController.view.bounds.height - bottomSafeArea
  }

  @objc
  public func cr_parentViewController() -> UIViewController? {
    var responder: UIResponder? = self
    while responder != nil {
      if responder is UIViewController {
        return responder as? UIViewController
      }
      responder = responder?.next
    }
    return nil
  }

  @objc
  public func cr_rootViewController() -> UIViewController? {
    var controller: UIViewController? = cr_parentViewController()
    while controller?.parent != nil {
      controller = controller?.parent
    }
    return controller
  }
}

extension Bool {
  public var stringValue: String {
    return self == true ? "true" : "false"
  }
}
