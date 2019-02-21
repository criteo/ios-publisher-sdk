//
//  CR_GdprUserConsent.h
//  pubsdk
//
//  Created by Adwait Kulkarni on 1/23/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef CR_GdprUserConsent_h
#define CR_GdprUserConsent_h

#import <Foundation/Foundation.h>

@interface CR_GdprUserConsent: NSObject

@property (readonly, nonatomic) NSString *consentString;
@property (readonly, nonatomic) BOOL gdprApplies;
@property (readonly, nonatomic) BOOL consentGiven;
@property (readonly, nonatomic) BOOL isAdTrackingEnabled;

@end
#endif /* CR_GdprUserConsent_h */
