//
// Created by Vincent Guerci on 16/03/2020.
// Copyright (c) 2020 Criteo. All rights reserved.
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

    func cgSize() -> CGSize? {
        switch self {
        case ._320x50:
            return CGSize(width: 320, height: 50)
        case ._300x250:
            return CGSize(width: 300, height: 250)
        }
    }
}

struct AdFormat: Hashable {
    let type: AdType
    let size: AdSize?

    init(type: AdType, size: AdSize?) {
        self.type = type
        self.size = size
    }

    init(type: AdType, size: AdSize) {
        self.init(type: type, size: .some(size))
    }

    init(type: AdType) {
        self.init(type: type, size: .none)
    }

    static func ==(lhs: AdFormat, rhs: AdFormat) -> Bool {
        return lhs.type == rhs.type && lhs.size == rhs.size
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.type.rawValue)
        hasher.combine(self.size?.rawValue)
    }

    static let banner320x50 = AdFormat(type: .banner, size: ._320x50)
    static let banner300x250 = AdFormat(type: .banner, size: ._300x250)
    static let native = AdFormat(type: .native)
    static let interstitial = AdFormat(type: .interstitial)
}
