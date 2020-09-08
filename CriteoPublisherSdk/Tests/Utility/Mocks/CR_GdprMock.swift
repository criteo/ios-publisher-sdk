//
//  CR_GdprMock.swift
//  CriteoPublisherSdkTests
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

public class CR_GdprMock: CR_Gdpr {

    @objc public var tcfVersionValue: CR_GdprTcfVersion = .versionUnknown
    @objc public var consentStringValue: String? = nil
    @objc public var appliesValue: NSNumber? = NSNumber(booleanLiteral: false)
    @objc public var purposeConsents: NSMutableArray =
      NSMutableArray(array: Array(repeating: NSNumber(true), count: 10 + 1)) // +1 for zero index

    override init(userDefaults: UserDefaults) {
        super.init(userDefaults: userDefaults)
    }

    @objc public func configure(tcfVersion: CR_GdprTcfVersion) {
        switch tcfVersion {
        case .versionUnknown:
            self.tcfVersionValue = .versionUnknown
            self.consentStringValue = nil
            self.appliesValue = NSNumber(booleanLiteral: false)
        case .version1_1:
            self.tcfVersionValue = .version1_1
            self.consentStringValue = NSString.gdprConsentStringForTcf1_1
            self.appliesValue = NSNumber(booleanLiteral: true)
        case .version2_0:
            self.tcfVersionValue = .version2_0
            self.consentStringValue = NSString.gdprConsentStringForTcf2_0
            self.appliesValue = NSNumber(booleanLiteral: true)
        @unknown default:
            fatalError()
        }
    }

    public override var consentString: String? {
        return consentStringValue
    }

    public override var tcfVersion: CR_GdprTcfVersion {
        return tcfVersionValue
    }

    public override var applies: NSNumber? {
        return appliesValue
    }

    public override func isConsentGiven(forPurpose id: UInt) -> Bool {
        return (purposeConsents[Int(id)] as! NSNumber).boolValue
    }
}
