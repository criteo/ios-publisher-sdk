//
//  MRAIDFeature.swift
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
import MessageUI

public struct MRAIDFeatures: Codable {
    var sms: Bool = false
    var tel: Bool = false

    public init() {
        if
            let telURL = URL(string: "tel://"),
            UIApplication.shared.canOpenURL(telURL) {
            self.tel = true
        }

        if MFMessageComposeViewController.canSendText() {
            self.sms = true
        }
    }
}
