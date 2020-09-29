//
//  CR_CacheManager.h
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

#ifndef CR_CacheManager_h
#define CR_CacheManager_h

#import <Foundation/Foundation.h>
#import "CR_CdbBid.h"
#import "CR_CacheAdUnit.h"

@interface CR_CacheManager : NSObject

@property(nonatomic, strong) NSMutableDictionary<CR_CacheAdUnit *, CR_CdbBid *> *bidCache;

- (CR_CacheAdUnit *)setBid:(CR_CdbBid *)bid;

- (CR_CdbBid *)getBidForAdUnit:(CR_CacheAdUnit *)adUnit;

- (void)removeBidForAdUnit:(CR_CacheAdUnit *)adUnit;

@end

#endif /* CR_CacheManager_h */
