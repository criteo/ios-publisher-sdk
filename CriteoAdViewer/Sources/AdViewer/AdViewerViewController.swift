//
//  AdViewerViewController.swift
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

class AdViewerViewController: FormViewController {
  private lazy var networks = AdNetworks(controller: self)
  private lazy var defaultNetwork = networks.all.first!

  private var adConfig: AdConfig?
  private var criteo: Criteo?
  private var interstitialView: InterstitialView?

  // MARK: form helper properties
  private enum Tags: String {
    case network, type, size, display, ads, publisherId
  }

  private enum DisplayMode: CustomStringConvertible {
    case onScreen, newView
    static func all() -> [DisplayMode] {
      return [.onScreen, .newView]
    }
    var description: String {
      switch self {
      case .onScreen: return "Below"
      case .newView: return "New View"
      }
    }
  }

  private var values: [String: Any?] {
    return self.form.values()
  }
  private var network: AdNetwork? {
    return self.values[Tags.network.rawValue] as? AdNetwork
  }
  private var type: AdType? {
    return self.values[Tags.type.rawValue] as? AdType
  }
  private var size: AdSize? {
    return self.values[Tags.size.rawValue] as? AdSize
  }
  private var display: DisplayMode? {
    return self.values[Tags.display.rawValue] as? DisplayMode
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    form = Section("Network")
      <<< SegmentedRow<AdNetwork>(Tags.network.rawValue) {
        $0.options = self.networks.all
        $0.value = $0.options?.first
        $0.displayValueFor = { network in
          network?.name
        }
        $0.onChange { (row: SegmentedRow<AdNetwork>) in
          if let network = row.value,
            let typeRow: SegmentedRow<AdType> = self.form.rowBy(tag: Tags.type.rawValue),
            let sizeRow: SegmentedRow<AdSize> = self.form.rowBy(tag: Tags.size.rawValue)
          {
            typeRow.options = network.types
            typeRow.value = typeRow.options?.first
            typeRow.reload()
            let sizes: [AdSize] = network.sizes(type: typeRow.value!)
            sizeRow.options = sizes
            sizeRow.value = sizeRow.options?.first
            sizeRow.reload()
          }
          self.updateAdConfig()
        }
      }

      +++ Section("Format")
      <<< SegmentedRow<AdType>(Tags.type.rawValue) {
        $0.options = defaultNetwork.types
        $0.value = $0.options?.first
        $0.displayValueFor = {
          $0?.label()
        }
        $0.onChange { _ in
          self.updateAdConfig()
        }
      }
      <<< SegmentedRow<AdSize>(Tags.size.rawValue) {
        $0.options = defaultNetwork.sizes(type: .banner)
        $0.value = $0.options?.first
        $0.displayValueFor = {
          $0?.label()
        }
        $0.hidden = .function([Tags.network.rawValue, Tags.type.rawValue]) { form in
          if let networkRow: SegmentedRow<AdNetwork> = self.form.rowBy(tag: Tags.network.rawValue),
            let typeRow: SegmentedRow<AdType> = self.form.rowBy(tag: Tags.type.rawValue),
            let sizeRow: SegmentedRow<AdSize> = self.form.rowBy(tag: Tags.size.rawValue),
            let network = networkRow.value,
            let type = typeRow.value
          {
            let sizeless = network.sizes(type: type).isEmpty
            if sizeless {
              sizeRow.value = .none
            }
            return sizeless
          }
          return false
        }
        $0.onChange { _ in
          self.updateAdConfig()
        }
      }

      +++ Section("Advanced options") {
        $0.hidden = .function(
          [Tags.network.rawValue, Tags.type.rawValue],
          { (form) -> Bool in
            if let typeRow: SegmentedRow<AdType> = self.form.rowBy(tag: Tags.type.rawValue),
              let type = typeRow.value
            {
              return type == .interstitial
            }
            return false
          })
      }
      <<< SegmentedRow<DisplayMode>(Tags.display.rawValue) {
        $0.options = DisplayMode.all()
        $0.value = $0.options?.first
        $0.displayValueFor = {
          $0?.description
        }
      }
      <<< TextRow(Tags.publisherId.rawValue) {
        $0.title = "Publisher ID"
        $0.placeholder = AdNetworks.defaultPublisherId
        $0.onChange { _ in
          self.updateAdConfig()
        }
      }

      +++ Section()
      <<< ButtonRow {
        $0.title = "Display Ad"
      }.onCellSelection { _, _ in
        self.displayAd()
      }

      +++ Section {
        $0.tag = Tags.ads.rawValue
      }

    self.updateAdConfig()
  }

  private func updateAdConfig() {
    if let adConfig = buildAdConfig() {
      self.adConfig = adConfig
      self.criteo = buildCriteo(adConfig: adConfig)
    }
  }

  private func buildAdConfig() -> AdConfig? {
    if let network = (self.values[Tags.network.rawValue] as? AdNetwork),
      let type = (self.values[Tags.type.rawValue] as? AdType)
    {
      let size = (self.values[Tags.size.rawValue] as? AdSize)
      let publisherId =
        (self.values[Tags.publisherId.rawValue] as? String)
        ?? AdNetworks.defaultPublisherId
      let format: AdFormat
      switch size {
      case .some(let size): format = .sized(type, size)
      case .none: format = .flexible(type)
      }
      if let adUnitId = network.defaultAdUnits[format] {
        return AdConfig(
          publisherId: publisherId,
          adUnitId: adUnitId,
          adFormat: format)
      } else {
        return .none
      }
    }
    return .none
  }

  private func buildCriteo(adConfig: AdConfig) -> Criteo {
    return buildCriteo(publisherId: adConfig.publisherId, adUnits: [adConfig.adUnit])
  }

  private func buildCriteo(publisherId: String, adUnits: [CRAdUnit]) -> Criteo {
    let criteo = Criteo()!
    criteo.networkManagerDelegate = LogManager.sharedInstance()
    criteo.registerPublisherId(publisherId, with: adUnits)
    return criteo
  }

  private func displayAd() {
    if let network = (self.values[Tags.network.rawValue] as? AdNetwork),
      let config = adConfig,
      let criteo = criteo
    {
      let adView = network.adViewBuilder.build(config: config, criteo: criteo)
      switch adView {
      case .banner(let bannerView):
        if self.display == .newView {
          let viewControler = AdTableViewController()
          viewControler.adView = bannerView
          self.navigationController?.pushViewController(viewControler, animated: true)
        } else if let adsSection = self.form.sectionBy(tag: Tags.ads.rawValue) {
          let adRow = AdViewRow<UIView>(bannerView.description) { (_) in
          }.cellSetup { (cell, _) in
            cell.view = bannerView
          }
          // Note: this is a workaround to missing insert method,
          //       to display new ad top first position
          let rows = adsSection.allRows
          adsSection.replaceSubrange(0..<rows.count, with: [adRow] + rows)
        }

      case .interstitial(let interstitialView):
        self.interstitialView = interstitialView
      }
    }
  }
}

extension AdViewerViewController: InterstitialUpdateDelegate {
  func interstitialUpdated(_ loaded: Bool) {
    if loaded, let interstitialView = self.interstitialView {
      interstitialView.present(viewController: self)
    }
  }
}
