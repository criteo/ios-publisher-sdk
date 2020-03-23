//
//  NSString+APIKeys.h
//  pubsdk
//
//  Created by Romain Lofaso on 3/23/20.
//  Copyright © 2020 Criteo. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (APIKeys)

#pragma mark General

@property (copy, nonatomic, class, readonly) NSString *userKey;

#pragma mark GDPR

@property (copy, nonatomic, class, readonly) NSString *gdprConsentKey;
@property (copy, nonatomic, class, readonly) NSString *gdprVersionKey;
@property (copy, nonatomic, class, readonly) NSString *gdprConsentDataKey;
@property (copy, nonatomic, class, readonly) NSString *gdprAppliesKey;
@property (copy, nonatomic, class, readonly) NSString *gdprConsentGivenKey;

#pragma mark US privacy

@property (copy, nonatomic, class, readonly) NSString *uspCriteoOptout;
@property (copy, nonatomic, class, readonly) NSString *uspIabKey;
@property (copy, nonatomic, class, readonly) NSString *mopubConsent;

@end

NS_ASSUME_NONNULL_END
