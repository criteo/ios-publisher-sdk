//
//  CdbBid.h
//  pubsdk
//
//  Created by Adwait Kulkarni on 12/10/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#ifndef CdbBid_h
#define CdbBid_h

#import <Foundation/Foundation.h>

@interface CdbBid : NSObject <NSCopying>

@property (readonly, nonatomic) NSString *placementId;
@property (readonly, nonatomic) NSNumber *zoneId;
@property (readonly, nonatomic) NSString *cpm;
@property (readonly, nonatomic) NSString *currency;
@property (readonly, nonatomic) NSNumber *width;
@property (readonly, nonatomic) NSNumber *height;
@property (readonly, nonatomic) NSTimeInterval ttl;
@property (readonly, nonatomic) NSString *creative;
@property (readonly, nonatomic) NSString *displayUrl;
@property (readonly, nonatomic) NSString *dfpCompatibleDisplayUrl;
@property (readonly, nonatomic) NSDate *insertTime;

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
                       creative:(NSString *) creative
                     displayUrl:(NSString *) displayUrl
// TODO: Move this to a state object
                     insertTime:(NSDate *) insertTime
NS_DESIGNATED_INITIALIZER;

- (instancetype) copyWithZone:(NSZone *) zone;
- (BOOL) isEqual:(CdbBid *) object;
- (BOOL) isEmpty;
- (BOOL) isExpired;
@end

#endif /* CdbBid_h */
