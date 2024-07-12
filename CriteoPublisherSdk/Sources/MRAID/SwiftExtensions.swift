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
    func fill(in container: UIView) {
        NSLayoutConstraint.activate([
          widthAnchor.constraint(equalTo: container.widthAnchor),
          heightAnchor.constraint(equalTo: container.heightAnchor),
          centerXAnchor.constraint(equalTo: container.centerXAnchor),
          centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }

    func removeAllConstraints() {
        removeConstraints(constraints)
    }

    public var isVisibleToUser: Bool {
        if isHidden || alpha == 0 || superview == nil || window == nil {
            return false
        }

        let keyWindow = UIApplication
            .shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .last { $0.isKeyWindow }

        guard let rootViewController = keyWindow?.rootViewController else {
            return false
        }

        let viewFrame = convert(bounds, to: rootViewController.view)
        let rootRectange = CGRect(origin: .zero, size: rootViewController.view.bounds.size)

        return rootRectange.intersects(viewFrame)
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

extension CGRect {
    public func contains(points: [CGPoint]) -> Bool {
        return points.filter({ !contains($0)}).isEmpty
    }
}
