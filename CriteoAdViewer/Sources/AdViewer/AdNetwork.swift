//
//  AdNetwork.swift
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

struct AdNetwork: Equatable {
  let name: String
  let supportedFormats: [AdFormat]
  let defaultAdUnits: [AdFormat: String]
  let adViewBuilder: AdViewBuilder

  init(
    name: String,
    supportedFormats: [AdFormat],
    defaultAdUnits: [AdFormat: String],
    adViewBuilder: AdViewBuilder
  ) {
    self.name = name
    self.supportedFormats = supportedFormats
    self.defaultAdUnits = defaultAdUnits
    self.adViewBuilder = adViewBuilder
  }

  var types: [AdType] {
    Array(
      Set(
        supportedFormats.map {
          switch $0 {
          case .sized(let type, _): return type
          case .flexible(let type): return type
          }
        })
    ).sorted {
      $0.rawValue < $1.rawValue
    }
  }

  func sizes(type: AdType) -> [AdSize] {
    self.supportedFormats.compactMap {
      switch $0 {
      case .sized(type, let size): return .some(size)
      case _: return .none
      }
    }
  }

  static func == (lhs: AdNetwork, rhs: AdNetwork) -> Bool {
    lhs.name == rhs.name
  }
}

struct AdNetworks {
  let google: AdNetwork
  let moPub: AdNetwork
  let standalone: AdNetwork
  let inHouse: AdNetwork
  let all: [AdNetwork]
  static let defaultPublisherId = "B-056946"

  init(controller: AdViewController) {
    self.google = googleNetwork(controller)
    self.moPub = moPubNetwork(controller: controller)
    self.standalone = standaloneNetwork(controller)
    self.inHouse = inHouseNetwork(controller: controller)
    self.all = [google, moPub, standalone, inHouse]
  }
}

private func googleNetwork(_ controller: AdViewController) -> AdNetwork {
  AdNetwork(
    name: "Google",
    supportedFormats: [
      AdFormat.banner320x50,
      AdFormat.banner300x250,
      AdFormat.native,
      AdFormat.interstitial,
      AdFormat.video,
    ],
    defaultAdUnits: [
      AdFormat.banner320x50: "/140800857/Endeavour_320x50",
      AdFormat.banner300x250: "/140800857/Endeavour_300x250",
      AdFormat.native: "/140800857/Endeavour_Native",
      AdFormat.interstitial: "/140800857/Endeavour_Interstitial_320x480",
      AdFormat.video: "/140800857/Endeavour_InterstitialVideo_320x480",
    ], adViewBuilder: GoogleAdViewBuilder(controller: controller))
}

let mopubBanner320x50AdUnitId = "bb0577af6858451d8191c2058fe59d03"

private func moPubNetwork(controller: AdViewController) -> AdNetwork {
  AdNetwork(
    name: "Mopub",
    supportedFormats: [
      AdFormat.banner320x50,
      AdFormat.banner300x250,
      AdFormat.interstitial,
      AdFormat.video,
    ],
    defaultAdUnits: [
      AdFormat.banner320x50: mopubBanner320x50AdUnitId,
      AdFormat.banner300x250: "69942486c90c4cd4b3c627ba613509a3",
      AdFormat.interstitial: "966fbbf95ba24ab990e5f037cc674bbc",
      AdFormat.video: "3e16381b52994475b18470d2ffcf360e",
    ],
    adViewBuilder: MopubAdViewBuilder(
      controller: controller,
      adUnitIdForAppInitialization: mopubBanner320x50AdUnitId))
}

private func standaloneNetwork(_ controller: AdViewController) -> AdNetwork {
  AdNetwork(
    name: "Standalone",
    supportedFormats: [
      AdFormat.banner320x50,
      AdFormat.interstitial,
      AdFormat.native,
    ],
    defaultAdUnits: [
      AdFormat.banner320x50: "30s6zt3ayypfyemwjvmp",
      AdFormat.interstitial: "6yws53jyfjgoq1ghnuqb",
      AdFormat.native: "190tsfngohsvfkh3hmkm",
    ], adViewBuilder: CriteoAdViewBuilder(controller: controller, type: .standalone))
}

private func inHouseNetwork(controller: AdViewController) -> AdNetwork {
  AdNetwork(
    name: "InHouse",
    supportedFormats: [
      AdFormat.banner320x50,
      AdFormat.interstitial,
    ],
    defaultAdUnits: [
      AdFormat.banner320x50: "30s6zt3ayypfyemwjvmp",
      AdFormat.interstitial: "6yws53jyfjgoq1ghnuqb",
    ], adViewBuilder: CriteoAdViewBuilder(controller: controller, type: .inHouse))
}
