//
//  NSString+APIKeys.h
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

NS_ASSUME_NONNULL_BEGIN

@interface NSString (APIKeys)

#pragma mark General

@property(copy, nonatomic, class, readonly) NSString *userKey;
@property(copy, nonatomic, class, readonly) NSString *sdkVersionKey;
@property(copy, nonatomic, class, readonly) NSString *publisherKey;
@property(copy, nonatomic, class, readonly) NSString *profileIdKey;

#pragma mark Publisher

@property(copy, nonatomic, class, readonly) NSString *bundleIdKey;
@property(copy, nonatomic, class, readonly) NSString *cpIdKey;

#pragma mark User

@property(copy, nonatomic, class, readonly) NSString *userAgentKey;
@property(copy, nonatomic, class, readonly) NSString *deviceIdKey;
@property(copy, nonatomic, class, readonly) NSString *deviceOsKey;
@property(copy, nonatomic, class, readonly) NSString *deviceModelKey;
@property(copy, nonatomic, class, readonly) NSString *deviceIdTypeKey;
@property(copy, nonatomic, class, readonly) NSString *deviceIdTypeValue;

#pragma mark GDPR

@property(copy, nonatomic, class, readonly) NSString *gdprConsentKey;
@property(copy, nonatomic, class, readonly) NSString *gdprConsentKeyForGum;
@property(copy, nonatomic, class, readonly) NSString *gdprVersionKey;
@property(copy, nonatomic, class, readonly) NSString *gdprConsentDataKey;
@property(copy, nonatomic, class, readonly) NSString *gdprAppliesKey;

#pragma mark US privacy

@property(copy, nonatomic, class, readonly) NSString *uspCriteoOptout;
@property(copy, nonatomic, class, readonly) NSString *uspIabKey;
@property(copy, nonatomic, class, readonly) NSString *mopubConsent;

@end

NS_ASSUME_NONNULL_END
