//
//  AdViewerViewController.swift
//  AdViewer
//
//  Created by Vincent Guerci on 10/03/2020.
//  Copyright © 2020 Criteo. All rights reserved.
//

import Eureka

class AdViewerViewController: FormViewController & InterstitialUpdateDelegate {
    private lazy var networks = AdNetworks(controller: self)
    private lazy var defaultNetwork = networks.all.first!

    private var adConfig: AdConfig?
    private var criteo: Criteo?
    private var interstitialView: InterstitialView?

    // MARK: form helper properties
    private enum tags: String {
        case network, type, size, ads
    }

    private var values: [String: Any?] {
        return self.form.values()
    }
    private var network: AdNetwork? {
        return self.values[tags.network.rawValue] as? AdNetwork
    }
    private var type: AdType? {
        return self.values[tags.type.rawValue] as? AdType
    }
    private var size: AdSize? {
        return self.values[tags.size.rawValue] as? AdSize
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        form = Section("Network")
        <<< SegmentedRow<AdNetwork>(tags.network.rawValue) {
            $0.options = self.networks.all
            $0.value = $0.options?.first
            $0.displayValueFor = { network in
                network?.name
            }
            $0.onChange { (row: SegmentedRow<AdNetwork>) in
                if let network = row.value,
                   let typeRow: SegmentedRow<AdType> = self.form.rowBy(tag: tags.type.rawValue),
                   let sizeRow: SegmentedRow<AdSize> = self.form.rowBy(tag: tags.size.rawValue) {
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
        <<< SegmentedRow<AdType>(tags.type.rawValue) {
            $0.options = defaultNetwork.types
            $0.value = $0.options?.first
            $0.displayValueFor = {
                $0?.label()
            }
            $0.onChange { _ in
                self.updateAdConfig()
            }
        }
        <<< SegmentedRow<AdSize>(tags.size.rawValue) {
            $0.options = defaultNetwork.sizes(type: .banner)
            $0.value = $0.options?.first
            $0.displayValueFor = {
                $0?.label()
            }
            $0.hidden = .function([tags.network.rawValue, tags.type.rawValue]) { form in
                if let networkRow: SegmentedRow<AdNetwork> = self.form.rowBy(tag: tags.network.rawValue),
                   let typeRow: SegmentedRow<AdType> = self.form.rowBy(tag: tags.type.rawValue),
                   let sizeRow: SegmentedRow<AdSize> = self.form.rowBy(tag: tags.size.rawValue),
                   let network = networkRow.value,
                   let type = typeRow.value {
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

        +++ Section()
        <<< ButtonRow() {
            $0.title = "Display Ad"
        }.onCellSelection { cell, row in
            self.displayAd()
        }

        +++ Section() {
            $0.tag = tags.ads.rawValue
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
        if let network = (self.values[tags.network.rawValue] as? AdNetwork),
           let type = (self.values[tags.type.rawValue] as? AdType) {
            let size = (self.values[tags.size.rawValue] as? AdSize)
            // TODO Advanced config
            let publisherId = "B-056946"
            let format = AdFormat(type: type, size: size)
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
        let criteo = Criteo()!
        criteo.networkMangerDelegate = LogManager.sharedInstance()
        criteo.registerPublisherId(adConfig.publisherId, with: [adConfig.adUnit])
        return criteo
    }

    private func displayAd() {
        if let network = (self.values[tags.network.rawValue] as? AdNetwork),
           let config = adConfig,
           let criteo = criteo {
            let adView = network.adViewBuilder.build(config: config, criteo: criteo)
            switch (adView) {
            case .banner(let bannerView):
                if let adsSection = self.form.sectionBy(tag: tags.ads.rawValue) {
                    let adRow = ViewRow<UIView>(bannerView.description) { (row) in
                    }.cellSetup { (cell, row) in
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

    func interstitialUpdated(_ loaded: Bool) {
        if loaded, let interstitialView = self.interstitialView {
            interstitialView.present(viewController: self)
        }
    }
}
