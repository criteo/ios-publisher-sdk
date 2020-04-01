//
//  CR_GdprMock.swift
//  pubsdkTests
//
//  Created by Romain Lofaso on 2/25/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

public class CR_GdprMock: CR_Gdpr {

    @objc public var tcfVersionValue: CR_GdprTcfVersion = .versionUnknown
    @objc public var consentStringValue: String? = nil
    @objc public var appliesValue: NSNumber? = NSNumber(booleanLiteral: false)

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

}
