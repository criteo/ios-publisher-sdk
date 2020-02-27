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
    @objc public var isAppliedValue: Bool = false
    @objc public var consentGivenToCriteoValue: Bool = false

    override init(userDefaults: UserDefaults) {
        super.init(userDefaults: userDefaults)
    }

    @objc public func configure(tcfVersion: CR_GdprTcfVersion) {
        switch tcfVersion {
        case .versionUnknown:
            self.tcfVersionValue = .versionUnknown
            self.consentStringValue = nil
            self.isAppliedValue = false
            self.consentGivenToCriteoValue = false
        case .version1_1:
            self.tcfVersionValue = .version1_1
            self.consentStringValue = NSString.gdprConsentStringForTcf1_1
            self.isAppliedValue = true
            self.consentGivenToCriteoValue = true
        case .version2_0:
            self.tcfVersionValue = .version2_0
            self.consentStringValue = NSString.gdprConsentStringForTcf2_0
            self.isAppliedValue = true
            self.consentGivenToCriteoValue = true
        @unknown default:
            fatalError()
        }
    }

    public override var consentString: String? {
        consentStringValue
    }

    public override var tcfVersion: CR_GdprTcfVersion {
        tcfVersionValue
    }

    public override var isApplied: Bool {
        isAppliedValue
    }

    public override var consentGivenToCriteo: Bool {
        consentGivenToCriteoValue
    }

}
