//
//  AdViewRow.swift
//  AdViewer
//
//  Created by Vincent Guerci on 10/03/2020.
//  Copyright © 2020 Criteo. All rights reserved.
//

import UIKit
import Eureka

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

        notificationObserver = NotificationCenter.default.addObserver(forName: UIContentSizeCategory.didChangeNotification,
                object: nil,
                queue: nil,
                using: { [weak self] (note) in
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
           view.superview != cell.contentView {
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
