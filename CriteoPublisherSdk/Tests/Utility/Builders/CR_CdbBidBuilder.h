//
//  CR_CdbBidBuilder.h
//  CriteoPublisherSdkTests
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

#import <Foundation/Foundation.h>

@class CR_CdbBid;
@class CR_CacheAdUnit;
@class CR_NativeAssets;
@class CR_SKAdNetworkParameters;

NS_ASSUME_NONNULL_BEGIN

#define PROPERTY_DECLARATION(name, type, ownership)                      \
  @property(nonatomic, readonly, copy) CR_CdbBidBuilder * (^name)(type); \
  @property(nonatomic, ownership) type name##Value;

@interface CR_CdbBidBuilder : NSObject

PROPERTY_DECLARATION(zoneId, NSUInteger, assign);
PROPERTY_DECLARATION(placementId, NSString *_Nullable, copy);
PROPERTY_DECLARATION(cpm, NSString *_Nullable, copy);
PROPERTY_DECLARATION(currency, NSString *_Nullable, copy);
PROPERTY_DECLARATION(width, NSUInteger, assign);
PROPERTY_DECLARATION(height, NSUInteger, assign);
PROPERTY_DECLARATION(ttl, NSTimeInterval, assign);
PROPERTY_DECLARATION(creative, NSString *_Nullable, copy);
PROPERTY_DECLARATION(displayUrl, NSString *_Nullable, copy);
PROPERTY_DECLARATION(isVideo, BOOL, assign);
PROPERTY_DECLARATION(insertTime, NSDate *_Nullable, copy);
PROPERTY_DECLARATION(nativeAssets, CR_NativeAssets *_Nullable, strong);
PROPERTY_DECLARATION(impressionId, NSString *_Nullable, copy);
PROPERTY_DECLARATION(skAdNetworkParameters, CR_SKAdNetworkParameters *_Nullable, copy);

/** Shortcut for placementId, width and height of the ad unit. */
@property(nonatomic, readonly, copy) CR_CdbBidBuilder * (^adUnit)(CR_CacheAdUnit *);

/** Commonly tested bid types */
@property(nonatomic, readonly, copy) CR_CdbBidBuilder * (^noBid)(void);
@property(nonatomic, readonly, copy) CR_CdbBidBuilder * (^expired)(void);
@property(nonatomic, readonly, copy) CR_CdbBidBuilder * (^silenced)(void);
@property(nonatomic, readonly, copy) CR_CdbBidBuilder * (^immediate)(void);

@property(nonatomic, readonly, strong) CR_CdbBid *build;
@property(nonatomic) BOOL isRewarded;

@end

#undef PROPERTY_DECLARATION

NS_ASSUME_NONNULL_END
