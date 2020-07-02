//
//  CR_TokenCache.h
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
#import "CRBidToken.h"
#import "CR_CdbBid.h"
#import "CR_TokenValue.h"

NS_ASSUME_NONNULL_BEGIN

@interface CR_TokenCache : NSObject

- (instancetype)init;

- (CRBidToken *)getTokenForBid:(CR_CdbBid *)cdbBid adUnitType:(CRAdUnitType)adUnitType;

- (nullable CR_TokenValue *)getValueForToken:(CRBidToken *)token
                                  adUnitType:(CRAdUnitType)adUnitType;

- (void)setTokenMapWithValue:(CR_TokenValue *)tokenValue forKey:(CRBidToken *)token;

- (CR_TokenValue *)tokenValueForKey:(CRBidToken *)token;

@end

NS_ASSUME_NONNULL_END
