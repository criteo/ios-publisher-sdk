//
//  CR_CdbRequest.h
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

#import <Foundation/Foundation.h>
#import "CR_CacheAdUnit.h"

@class CR_CdbResponse;

NS_ASSUME_NONNULL_BEGIN

@interface CR_CdbRequest : NSObject

@property(strong, nonatomic, readonly) NSNumber *profileId;
@property(strong, nonatomic, readonly) NSString *requestGroupId;
@property(strong, nonatomic, readonly) CR_CacheAdUnitArray *adUnits;
@property(strong, nonatomic, readonly) NSArray<NSString *> *impressionIds;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithProfileId:(NSNumber *)profileId
                          adUnits:(CR_CacheAdUnitArray *)adUnits NS_DESIGNATED_INITIALIZER;

- (NSString *)impressionIdForAdUnit:(CR_CacheAdUnit *)adUnit;

- (NSArray<NSString *> *)impressionIdsMissingInCdbResponse:(CR_CdbResponse *)cdbResponse;

@end

NS_ASSUME_NONNULL_END
