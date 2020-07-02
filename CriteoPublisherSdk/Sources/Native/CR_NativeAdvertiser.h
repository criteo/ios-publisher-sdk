//
//  CR_NativeAdvertiser.h
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

@interface CR_NativeAdvertiser : NSObject <NSCopying>

@property(readonly, copy, nonatomic) NSString *description;
@property(readonly, copy, nonatomic) NSString *domain;
@property(readonly, copy, nonatomic) CR_NativeImage *logoImage;
@property(readonly, copy, nonatomic) NSString *logoClickUrl;

- (instancetype)initWithDict:(NSDictionary *)jdict;
+ (CR_NativeAdvertiser *)nativeAdvertiserWithDict:(NSDictionary *)jdict;

@end
