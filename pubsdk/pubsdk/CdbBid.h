//
//  CdbResponse.h
//  pubsdk
//
//  Created by Adwait Kulkarni on 12/10/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#ifndef CdbResponse_h
#define CdbResponse_h

#import <Foundation/Foundation.h>

@interface CdbBid : NSObject <NSCopying>

@property (readonly, nonatomic) NSString *placementId;
@property (readonly, nonatomic) NSNumber *zoneId;
@property (readonly, nonatomic) NSNumber *cpm;
@property (readonly, nonatomic) NSString *currency;
@property (readonly, nonatomic) NSNumber *width;
@property (readonly, nonatomic) NSNumber *height;
@property (readonly, nonatomic) NSNumber *ttl;
@property (readonly, nonatomic) NSString *creative;
@property (readonly, nonatomic) NSString *displayUrl;

+ (instancetype) emptyBid;
+ (NSArray *) getCdbResponsesFromData: (NSData *) data;

- (instancetype) initWithZoneId:(NSNumber *) zoneId
                    placementId:(NSString *) placementId
                            cpm:(NSNumber *) cpm
                       currency:(NSString *) currency
                          width:(NSNumber *) width
                         height:(NSNumber *) height
                            ttl:(NSNumber *) ttl
                       creative:(NSString *) creative
                     displayUrl:(NSString *) displayUrl
NS_DESIGNATED_INITIALIZER;

- (instancetype) copyWithZone:(NSZone *) zone;
- (BOOL) isEqual:(CdbBid *) object;
- (BOOL) isEmpty;

@end

#endif /* CdbResponse_h */
