//
// Created by Vincent Guerci on 16/03/2020.
// Copyright (c) 2020 Criteo. All rights reserved.
//

struct AdNetwork: Equatable {
    let name: String
    let supportedFormats: [AdFormat]
    let defaultAdUnits: [AdFormat: String]

    init(name: String,
         supportedFormats: [AdFormat],
         defaultAdUnits: [AdFormat: String]) {
        self.name = name
        self.supportedFormats = supportedFormats
        self.defaultAdUnits = defaultAdUnits
    }

    var types: [AdType] {
        return Array(Set(supportedFormats.map {
            return $0.type
        })).sorted {
            return $0.rawValue < $1.rawValue
        }
    }

    func sizes(type: AdType) -> [AdSize] {
        return self.supportedFormats.filter {
            return $0.type == type
        }.compactMap {
            return $0.size
        }
    }

    static func ==(lhs: AdNetwork, rhs: AdNetwork) -> Bool {
        return lhs.name == rhs.name
    }
}

struct AdNetworks {
    static let Google = AdNetwork(name: "Google", supportedFormats: [
        AdFormat.banner320x50,
        AdFormat.banner300x250,
        AdFormat.native,
        AdFormat.interstitial,
    ], defaultAdUnits: [
        AdFormat.banner320x50: "/140800857/Endeavour_320x50",
        AdFormat.banner300x250: "/140800857/Endeavour_300x250",
        AdFormat.native: "/140800857/Endeavour_Native",
        AdFormat.interstitial: "/140800857/Endeavour_Interstitial_320x480",
    ])
    static let Mopub = AdNetwork(name: "Mopub", supportedFormats: [
        AdFormat.banner320x50,
        AdFormat.banner300x250,
        AdFormat.interstitial,
    ], defaultAdUnits: [
        AdFormat.banner320x50: "bb0577af6858451d8191c2058fe59d03",
        AdFormat.banner300x250: "69942486c90c4cd4b3c627ba613509a3",
        AdFormat.interstitial: "966fbbf95ba24ab990e5f037cc674bbc",
    ])
    static let Criteo = AdNetwork(name: "Standalone", supportedFormats: [
        AdFormat.banner320x50,
        AdFormat.interstitial,
    ], defaultAdUnits: [
        AdFormat.banner320x50: "30s6zt3ayypfyemwjvmp",
        AdFormat.interstitial: "6yws53jyfjgoq1ghnuqb",
    ])
    static let all = [Google, Mopub, Criteo]
}
