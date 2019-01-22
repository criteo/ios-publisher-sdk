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

@property (readonly, atomic) NSString *consentString;
@property (readonly, atomic) BOOL gdprApplies;
@property (readonly, atomic) BOOL consentGiven;

@end
#endif /* GdprUserConsent_h */
