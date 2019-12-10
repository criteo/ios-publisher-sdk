//
//  CR_DataProtectionConsent.h
//  pubsdk
//
//  Created by Adwait Kulkarni on 1/23/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef CR_DataProtectionConsent_h
#define CR_DataProtectionConsent_h

#import <Foundation/Foundation.h>

@interface CR_DataProtectionConsent: NSObject

@property (copy, readonly, nonatomic) NSString *consentString;
@property (readonly, nonatomic) BOOL gdprApplies;
@property (readonly, nonatomic) BOOL consentGiven;
@property (readonly, nonatomic) BOOL isAdTrackingEnabled;

@end
#endif /* CR_DataProtectionConsent_h */
