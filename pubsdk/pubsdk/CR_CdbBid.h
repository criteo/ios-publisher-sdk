//
//  CR_CdbBid.h
//  pubsdk
//
//  Copyright © 2018 Criteo. All rights reserved.
//

#ifndef CR_CdbBid_h
#define CR_CdbBid_h

#import <Foundation/Foundation.h>
#import "CR_NativeAssets.h"

@interface CR_CdbBid : NSObject <NSCopying>

@property (readonly, nonatomic) NSString *placementId;
@property (readonly, nonatomic) NSNumber *zoneId;
@property (readonly, nonatomic) NSString *cpm;
@property (readonly, nonatomic) NSString *currency;
@property (readonly, nonatomic) NSNumber *width;
@property (readonly, nonatomic) NSNumber *height;
@property (readonly) NSTimeInterval ttl;
@property (readonly, nonatomic) NSString *creative;
@property (readonly, nonatomic) NSString *displayUrl;
@property (readonly, nonatomic) NSString *dfpCompatibleDisplayUrl;
@property (readonly, nonatomic) NSString *mopubCompatibleDisplayUrl;
@property (readonly, nonatomic) NSString *impressionId;
@property (readonly, nonatomic) NSDate *insertTime;
@property (readonly, copy, nonatomic) CR_NativeAssets *nativeAssets;
@property (readonly) BOOL isValid;
@property (nonatomic, assign, readonly) BOOL isInSilenceMode;

/**
 * YES if a new bid can be fetched for the AdUnit
 *  according to its silence mode and its expiration.
 */
@property (assign, nonatomic, readonly) BOOL isRenewable;

+ (instancetype) emptyBid;

/*
 * Helper function to convert NSData returned from a network call
 * to an Array of CDB-Bids
 */
+ (NSArray *) getCdbResponsesForData: (NSData *) data
                          receivedAt: (NSDate *) receivedAt;

- (instancetype) initWithZoneId:(NSNumber *) zoneId
                    placementId:(NSString *) placementId
                            cpm:(NSString *) cpm
                       currency:(NSString *) currency
                          width:(NSNumber *) width
                         height:(NSNumber *) height
                            ttl:(NSTimeInterval) ttl
                       creative:(NSString *) creative   // creative is an useless legacy field
                     displayUrl:(NSString *) displayUrl
                     insertTime:(NSDate *) insertTime   // TODO: Move this to a state object
                   nativeAssets:(CR_NativeAssets *) nativeAssets
                   impressionId:(NSString *) impressionId;

- (instancetype) initWithDict:(NSDictionary *)slot receivedAt:(NSDate *)receivedAt;
- (BOOL) isEmpty;
- (BOOL) isExpired;
- (BOOL) isValid;

@end

#endif /* CR_CdbBid_h */
