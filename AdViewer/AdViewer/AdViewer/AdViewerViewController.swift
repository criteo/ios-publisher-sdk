//
//  AdViewerViewController.swift
//  AdViewer
//
//  Created by Vincent Guerci on 10/03/2020.
//  Copyright © 2020 Criteo. All rights reserved.
//

import UIKit
import Eureka

class AdViewerViewController: FormViewController {
    private let networks = AdNetworks.all

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

        let defaultNetwork = networks[0]
        form = Section("Network")
        <<< SegmentedRow<AdNetwork>(tags.network.rawValue) {
            $0.options = self.networks
            $0.value = $0.options?[0]
            $0.displayValueFor = { network in
                network?.name
            }
            $0.onChange { (row: SegmentedRow<AdNetwork>) in
                if let network = row.value,
                   let typeRow: SegmentedRow<AdType> = self.form.rowBy(tag: tags.type.rawValue),
                   let sizeRow: SegmentedRow<AdSize> = self.form.rowBy(tag: tags.size.rawValue) {
                    typeRow.options = network.types
                    typeRow.value = typeRow.options?[0]
                    typeRow.reload()
                    let sizes: [AdSize] = network.sizes(type: typeRow.value!)
                    sizeRow.options = sizes
                    sizeRow.value = sizeRow.options?[0]
                    sizeRow.reload()
                }
            }
        }

        +++ Section("Format")
        <<< SegmentedRow<AdType>(tags.type.rawValue) {
            $0.options = defaultNetwork.types
            $0.value = $0.options?[0]
            $0.displayValueFor = {
                $0?.label()
            }
        }
        <<< SegmentedRow<AdSize>(tags.size.rawValue) {
            $0.options = defaultNetwork.sizes(type: .banner)
            $0.value = $0.options?[0]
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
    }

    private func displayAd() {
        //TODO
    }
}
