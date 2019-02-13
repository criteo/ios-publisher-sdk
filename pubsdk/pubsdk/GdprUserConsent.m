//
//  GdprUserConsent.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 1/23/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "GdprUserConsent.h"
#import <AdSupport/ASIdentifierManager.h>

@implementation GdprUserConsent;
/* IAB spec is https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/Mobile%20In-App%20Consent%20APIs%20v1.0%20Final.md#structure
 */
- (instancetype) init {
    if(self = [super init]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        _gdprApplies = [userDefaults boolForKey:@"IABConsent_SubjectToGDPR"];
        _consentString = [userDefaults stringForKey:@"IABConsent_ConsentString"];
        // set to default
        _consentGiven = NO;
        NSString *vendorConsents = [userDefaults stringForKey:@"IABConsent_ParsedVendorConsents"];
        // Criteo is vendor id 91
        if(vendorConsents.length >= 91 && [vendorConsents characterAtIndex:90] == '1') {
            _consentGiven = YES;
        }
        _isAdTrackingEnabled = [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
    }
    return self;
}

@end
