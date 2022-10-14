//
//  AdTableViewController.swift
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
    case typeBasic
    case typeAd
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellType.typeBasic.rawValue)
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellType.typeAd.rawValue)
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

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell {
    if indexPath == adCellIndexPath {
      let cell = tableView.dequeueReusableCell(
        withIdentifier: CellType.typeAd.rawValue,
        for: indexPath)
      if let adView = adView {
        adView.frame = CGRect(
          x: 0, y: 0,
          width: adView.frame.size.width,
          height: adView.frame.size.height)
        adView.removeFromSuperview()
        cell.contentView.addSubview(adView)
      }
      return cell
    }

    let cell = tableView.dequeueReusableCell(
      withIdentifier: CellType.typeBasic.rawValue,
      for: indexPath)
    cell.textLabel?.text = "Cell \(indexPath.row + 1)"
    return cell
  }
}
