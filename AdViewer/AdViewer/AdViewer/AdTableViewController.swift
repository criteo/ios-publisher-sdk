//
//  AdTableViewController.swift
//  AdViewer
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

import UIKit

class AdTableViewController: UITableViewController {

    public var adView: UIView? {
        willSet {
            adView?.removeFromSuperview()
        }
    }

    private let adCellIndexPath = IndexPath(row: 10, section: 0)
    private let numberOfCells = 50

    private enum CellType: String {
        case basic, ad
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellType.basic.rawValue)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellType.ad.rawValue)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfCells
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height / CGFloat(adCellIndexPath.row / 2)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath == adCellIndexPath {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellType.ad.rawValue,
                                                     for: indexPath)
            if let adView = adView {
                adView.frame = CGRect(
                    x: 0, y: 0,
                    width: adView.frame.size.width,
                    height: adView.frame.size.height)
                adView.removeFromSuperview()
                cell.contentView.addSubview(adView)
            }
            return cell;
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: CellType.basic.rawValue,
                                                 for: indexPath)
        cell.textLabel?.text = "Cell \(indexPath.row + 1)"
        return cell
    }
}
