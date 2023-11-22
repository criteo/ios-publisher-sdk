//
//  CR_SKAdNetworkFidelityParameter.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2023 Criteo. All rights reserved.
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

NS_ASSUME_NONNULL_BEGIN

@interface CR_SKAdNetworkFidelityParameter : NSObject

#pragma mark - Properties
/** Ad type */
@property(nonatomic, copy, nullable) NSNumber *fidelity;
/** Timestamp of the ad impression */
@property(nonatomic, copy, nullable) NSNumber *timestamp;
/** Unique UUID random value used for added security */
@property(nonatomic, copy, nullable) NSUUID *nonce;
/** Advertising network’s cryptographic signature used for install validation */
@property(nonatomic, copy, nullable) NSString *signature;

#pragma mark - Lifecycle

- (instancetype)initWithDict:(NSDictionary *)dict;
- (instancetype)initWithFidelity:(NSNumber *)fidelity
                       timestamp:(NSNumber *)timestamp
                           nonce:(NSUUID *)nonce
                       signature:(NSString *)signature;

@end

NS_ASSUME_NONNULL_END
