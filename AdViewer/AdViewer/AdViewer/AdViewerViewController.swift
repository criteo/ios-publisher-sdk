//
//  AdViewerViewController.swift
//  AdViewer
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

import Eureka

class AdViewerViewController: FormViewController {
    private lazy var networks = AdNetworks(controller: self)
    private lazy var defaultNetwork = networks.all.first!
    // TODO Advanced config
    private let publisherId = "B-056946"

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

        /* //Load Test
        +++ Section()
        <<< ButtonRow() {
            $0.title = "Load Test"
        }.onCellSelection { cell, row in
            self.loadTestAd()
        } */

        +++ Section() {
            $0.tag = tags.ads.rawValue
        }

        self.updateAdConfig()
    }

    private func loadTestAd(iterations: Int = 1000) {
        if let network = (self.values[tags.network.rawValue] as? AdNetwork) {
            let configs = network.defaultAdUnits.map { format, adUnitId -> AdConfig in
                return AdConfig(
                        publisherId: publisherId,
                        adUnitId: adUnitId,
                        adFormat: format)
            }
            var adViewCounter = 0
            let adUnits = configs.map { return $0.adUnit }
            let criteo = buildCriteo(adUnits: adUnits)
            sleep(3) // FIXME: waiting for register
            let queue = DispatchQueue(label: "loadTestQueue", attributes: .concurrent)
            let group = DispatchGroup()
            for _ in 1...iterations {
                configs.forEach { config in
                    group.enter()
                    queue.async {
                        network.adViewBuilder.build(config: config, criteo: criteo)
                        group.leave()
                    }
                }
                adViewCounter += configs.count
            }
            group.wait()
            print("Loaded \(adViewCounter) adViews")
        }
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
        return buildCriteo(adUnits: [adConfig.adUnit])
    }

    private func buildCriteo(adUnits: [CRAdUnit]) -> Criteo {
        let criteo = Criteo()!
        criteo.networkManagerDelegate = LogManager.sharedInstance()
        criteo.registerPublisherId(self.publisherId, with: adUnits)
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
                    let adRow = AdViewRow<UIView>(bannerView.description) { (row) in
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
}

extension AdViewerViewController: InterstitialUpdateDelegate {
    func interstitialUpdated(_ loaded: Bool) {
        if loaded, let interstitialView = self.interstitialView {
            interstitialView.present(viewController: self)
        }
    }
}
