//
//  AdViewRow.swift
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

import Eureka
import UIKit

private class AdViewConstants {
  static let padding: CGFloat = 4
  static let backgroundColor = UIColor(white: 0.5, alpha: 0.5)
}

public class AdViewCell<ViewType: UIView, ValueType: Equatable>: Cell<ValueType>, CellType {
  public var view: ViewType?

  private var notificationObserver: NSObjectProtocol?

  required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    if let notificationObserver = notificationObserver {
      NotificationCenter.default.removeObserver(notificationObserver)
    }
  }

  open override func setup() {
    super.setup()

    height = {
      (self.view?.frame.height ?? 0.0) + AdViewConstants.padding * 4
    }

    notificationObserver = NotificationCenter.default.addObserver(
      forName: UIContentSizeCategory.didChangeNotification,
      object: nil,
      queue: nil,
      using: { [weak self] (_) in
        self?.setNeedsLayout()
      })

    selectionStyle = .none
    backgroundColor = AdViewConstants.backgroundColor
  }

  open override func didSelect() {
  }

  open override func layoutSubviews() {
    super.layoutSubviews()
    view?.center = contentView.center
  }

}

public final class AdViewRow<ViewType: UIView>: Row<AdViewCell<ViewType, String>>, RowType {
  override public func updateCell() {
    //  NOTE: super.updateCell() deliberately not called.

    //  Deal with the case where the caller did not add their custom view to the containerView in a
    //  backwards compatible manner.
    if let view = cell.view,
      view.superview != cell.contentView
    {
      view.backgroundColor = AdViewConstants.backgroundColor
      view.removeFromSuperview()
      cell.contentView.addSubview(view)
    }
  }

  required public init(tag: String?) {
    super.init(tag: tag)
    displayValueFor = nil
  }
}
