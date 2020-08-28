//
//  AdFormat.swift
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

enum AdType: Int {
    case banner, native, interstitial

    func label() -> String {
        switch self {
        case .banner: return "Banner"
        case .native: return "Native"
        case .interstitial: return "Interstitial"
        }
    }
}

enum AdSize: Int {
    case _320x50, _300x250

    func label() -> String {
        switch self {
        case ._320x50: return "320x50"
        case ._300x250: return "300x250"
        }
    }

    func cgSize() -> CGSize {
        switch self {
        case ._320x50:
            return CGSize(width: 320, height: 50)
        case ._300x250:
            return CGSize(width: 300, height: 250)
        }
    }
}

enum AdFormat: Hashable {
    case sized(AdType, AdSize)
    case flexible(AdType)

    static let banner320x50 = AdFormat.sized(.banner, ._320x50)
    static let banner300x250 = AdFormat.sized(.banner, ._300x250)
    static let native = AdFormat.flexible(.native)
    static let interstitial = AdFormat.flexible(.interstitial)
}
