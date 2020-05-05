//
// Copyright © 2018-2020 Criteo. All rights reserved.
//

struct AdNetwork: Equatable {
    let name: String
    let supportedFormats: [AdFormat]
    let defaultAdUnits: [AdFormat: String]
    let adViewBuilder: AdViewBuilder

    init(name: String,
         supportedFormats: [AdFormat],
         defaultAdUnits: [AdFormat: String],
         adViewBuilder: AdViewBuilder) {
        self.name = name
        self.supportedFormats = supportedFormats
        self.defaultAdUnits = defaultAdUnits
        self.adViewBuilder = adViewBuilder
    }

    var types: [AdType] {
        return Array(Set(supportedFormats.map {
            switch $0 {
            case .sized(let type, _): return type
            case .flexible(let type): return type
            }
        })).sorted {
            return $0.rawValue < $1.rawValue
        }
    }

    func sizes(type: AdType) -> [AdSize] {
        return self.supportedFormats.compactMap {
            switch $0 {
            case .sized(type, let size): return .some(size)
            case _: return .none
            }
        }
    }

    static func ==(lhs: AdNetwork, rhs: AdNetwork) -> Bool {
        return lhs.name == rhs.name
    }
}

struct AdNetworks {
    let Google: AdNetwork
    let Mopub: AdNetwork
    let Criteo: AdNetwork
    let all: [AdNetwork]

    init(controller: AdViewController) {
        self.Google = AdNetwork(name: "Google", supportedFormats: [
            AdFormat.banner320x50,
            AdFormat.banner300x250,
            AdFormat.native,
            AdFormat.interstitial,
        ], defaultAdUnits: [
            AdFormat.banner320x50: "/140800857/Endeavour_320x50",
            AdFormat.banner300x250: "/140800857/Endeavour_300x250",
            AdFormat.native: "/140800857/Endeavour_Native",
            AdFormat.interstitial: "/140800857/Endeavour_Interstitial_320x480",
        ], adViewBuilder: GoogleAdViewBuilder(controller: controller))

        let mopubBanner320x50AdUnitId = "bb0577af6858451d8191c2058fe59d03"
        self.Mopub = AdNetwork(name: "Mopub", supportedFormats: [
            AdFormat.banner320x50,
            AdFormat.banner300x250,
            AdFormat.interstitial,
        ], defaultAdUnits: [
            AdFormat.banner320x50: mopubBanner320x50AdUnitId,
            AdFormat.banner300x250: "69942486c90c4cd4b3c627ba613509a3",
            AdFormat.interstitial: "966fbbf95ba24ab990e5f037cc674bbc",
        ], adViewBuilder: MopubAdViewBuilder(controller: controller,
                adUnitIdForAppInitialization: mopubBanner320x50AdUnitId))

        self.Criteo = AdNetwork(name: "Standalone", supportedFormats: [
            AdFormat.banner320x50,
            AdFormat.interstitial,
            AdFormat.native,
        ], defaultAdUnits: [
            AdFormat.banner320x50: "30s6zt3ayypfyemwjvmp",
            AdFormat.interstitial: "6yws53jyfjgoq1ghnuqb",
            AdFormat.native: "190tsfngohsvfkh3hmkm",
        ], adViewBuilder: StandaloneAdViewBuilder(controller: controller))

        self.all = [Google, Mopub, Criteo]
    }
}
