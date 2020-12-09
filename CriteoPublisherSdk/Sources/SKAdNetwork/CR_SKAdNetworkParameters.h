//
//  CR_SKAdNetworkParameters.h
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

NS_ASSUME_NONNULL_BEGIN

@interface CR_SKAdNetworkParameters : NSObject <NSCopying>

#pragma mark - Properties

/** Advertising network’s unique identifier */
@property(nonatomic, copy, nullable) NSString *networkId;
/** Version of the ad network API, “2.0” */
@property(nonatomic, copy, nullable) NSString *version;
/** Advertising network's campaign identifier */
@property(nonatomic, copy, nullable) NSNumber *campaignId;
/** iTunes identifier for the item you want the store to display */
@property(nonatomic, copy, nullable) NSNumber *iTunesItemId;
/** Unique UUID random value used for added security */
@property(nonatomic, copy, nullable) NSUUID *nonce;
/** Timestamp of the ad impression */
@property(nonatomic, copy, nullable) NSNumber *timestamp;
/** App Store ID of the app that displays the ad */
@property(nonatomic, copy, nullable) NSNumber *sourceAppId;
/** Advertising network’s cryptographic signature used for install validation */
@property(nonatomic, copy, nullable) NSString *signature;

#pragma mark - Lifecycle

- (instancetype)initWithDict:(NSDictionary *)dict;
- (instancetype)initWithNetworkId:(NSString *)networkId
                          version:(NSString *)version
                       campaignId:(NSNumber *)campaignId
                     iTunesItemId:(NSNumber *)iTunesItemId
                            nonce:(NSUUID *)nonce
                        timestamp:(NSNumber *)timestamp
                      sourceAppId:(NSNumber *)sourceAppId
                        signature:(NSString *)signature;

#pragma mark - Load Product

- (NSDictionary *)toLoadProductParameters;

@end

NS_ASSUME_NONNULL_END
