//
//  CR_NativeAssets.h
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
#import "CR_NativeProduct.h"
#import "CR_NativeAdvertiser.h"
#import "CR_NativePrivacy.h"
#import "NSArray+Criteo.h"

@interface CR_NativeAssets : NSObject <NSCopying>

// Products array, BidManager ensure we have at least one entry, or bid is considered invalid
@property(readonly, copy, nonatomic) CR_NativeProductArray *products;
@property(readonly, copy, nonatomic) CR_NativeAdvertiser *advertiser;
@property(readonly, copy, nonatomic) CR_NativePrivacy *privacy;
@property(readonly, copy, nonatomic) NSArray<NSString *> *impressionPixels;

- (instancetype)initWithDict:(NSDictionary *)jdict;

@end
