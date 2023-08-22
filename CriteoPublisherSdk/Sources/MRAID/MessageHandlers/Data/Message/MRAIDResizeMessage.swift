//
//  MRAIDResizeMessage.swift
//  CriteoPublisherSdk
//
//  Copyright © 2018-2023 Criteo. All rights reserved.
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

import Foundation

public struct MRAIDResizeMessage: Decodable {
    let action: Action
    let width: Int
    let height: Int
    let offsetX: Int
    let offsetY: Int
    let customClosePosition: MRAIDCustomClosePosition
    let allowOffscreen: Bool

    enum CodingKeys: CodingKey {
        case action
        case width
        case height
        case offsetX
        case offsetY
        case customClosePosition
        case allowOffscreen
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.action = try container.decode(Action.self, forKey: .action)
        self.width = try container.decode(Int.self, forKey: .width)
        self.height = try container.decode(Int.self, forKey: .height)
        self.offsetX = try container.decode(Int.self, forKey: .offsetX)
        self.offsetY = try container.decode(Int.self, forKey: .offsetY)
        self.customClosePosition = try container.decodeIfPresent(MRAIDCustomClosePosition.self, forKey: .customClosePosition) ?? .topRight
        self.allowOffscreen = try container.decodeIfPresent(Bool.self, forKey: .allowOffscreen) ?? true
    }

    init(action: Action, width: Int, height: Int, offsetX: Int, offsetY: Int, customClosePosition: MRAIDCustomClosePosition, allowOffscreen: Bool) {
        self.action = action
        self.width = width
        self.height = height
        self.offsetX = offsetX
        self.offsetY = offsetY
        self.customClosePosition = customClosePosition
        self.allowOffscreen = allowOffscreen
    }
}
