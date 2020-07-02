//
//  CR_NativeProduct.h
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
#import "CR_NativeImage.h"

@interface CR_NativeProduct : NSObject <NSCopying>

@property(readonly, copy, nonatomic) NSString *title;
@property(readonly, copy, nonatomic) NSString *description;
@property(readonly, copy, nonatomic) NSString *price;
@property(readonly, copy, nonatomic) NSString *clickUrl;
@property(readonly, copy, nonatomic) NSString *callToAction;
@property(readonly, copy, nonatomic) CR_NativeImage *image;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (CR_NativeProduct *)nativeProductWithDict:(NSDictionary *)dict;

typedef NSArray<CR_NativeProduct *> CR_NativeProductArray;
typedef NSMutableArray<CR_NativeProduct *> CR_MutableNativeProductArray;

@end
