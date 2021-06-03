//
//  CR_CdbBid.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#ifndef CR_CdbBid_h
#define CR_CdbBid_h

#import <Foundation/Foundation.h>
#import "CR_NativeAssets.h"
#import "CR_SKAdNetworkParameters.h"

@interface CR_CdbBid : NSObject <NSCopying>

@property(readonly, nonatomic) NSString *placementId;
@property(readonly, nonatomic) NSNumber *zoneId;
@property(readonly, nonatomic) NSString *cpm;
@property(readonly, nonatomic) NSString *currency;
@property(readonly, nonatomic) NSNumber *width;
@property(readonly, nonatomic) NSNumber *height;
@property(readonly) NSTimeInterval ttl;
@property(readonly, nonatomic) NSString *creative;
@property(readonly, nonatomic) NSString *displayUrl;
@property(readonly, nonatomic) NSString *impressionId;
@property(readonly) BOOL isVideo;
@property(readonly, nonatomic) NSDate *insertTime;
@property(readonly, copy, nonatomic) CR_NativeAssets *nativeAssets;
@property(readonly, copy, nonatomic) CR_SKAdNetworkParameters *skAdNetworkParameters;
@property(readonly) BOOL isValid;
@property(nonatomic, assign, readonly) BOOL isInSilenceMode;

/**
 * YES if a new bid can be fetched for the AdUnit
 *  according to its silence mode and its expiration.
 */
@property(assign, nonatomic, readonly) BOOL isRenewable;

/**
 * YES if a bid is "immediate". i.e. CPM > 0, TTL = 0
 */
@property(assign, nonatomic, readonly) BOOL isImmediate;

+ (instancetype)emptyBid;

+ (NSArray<CR_CdbBid *> *)cdbBidsWithSlots:(NSArray *)slots receivedAt:(NSDate *)receivedAt;

- (instancetype)initWithZoneId:(NSNumber *)zoneId
                   placementId:(NSString *)placementId
                           cpm:(NSString *)cpm
                      currency:(NSString *)currency
                         width:(NSNumber *)width
                        height:(NSNumber *)height
                           ttl:(NSTimeInterval)ttl
                      creative:(NSString *)creative  // creative is an useless legacy field
                    displayUrl:(NSString *)displayUrl
                       isVideo:(BOOL)isVideo
                    insertTime:(NSDate *)insertTime  // TODO: Move this to a state object
                  nativeAssets:(CR_NativeAssets *)nativeAssets
                  impressionId:(NSString *)impressionId
         skAdNetworkParameters:(CR_SKAdNetworkParameters *)skAdNetworkParameters;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithDict:(NSDictionary *)slot receivedAt:(NSDate *)receivedAt;
- (BOOL)isEmpty;
- (BOOL)isExpired;
- (BOOL)isValid;

- (void)setDefaultTtl;

@end

#endif /* CR_CdbBid_h */
