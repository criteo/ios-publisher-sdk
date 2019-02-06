//
//  GdprUserConsent.h
//  pubsdk
//
//  Created by Adwait Kulkarni on 1/23/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef GdprUserConsent_h
#define GdprUserConsent_h

#import <Foundation/Foundation.h>

@interface GdprUserConsent: NSObject

@property (readonly, nonatomic) NSString *consentString;
@property (readonly, nonatomic) BOOL gdprApplies;
@property (readonly, nonatomic) BOOL consentGiven;
@property (readonly, nonatomic) BOOL isAdTrackingEnabled;

@end
#endif /* GdprUserConsent_h */
