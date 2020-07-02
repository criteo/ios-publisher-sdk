//
//  NSString+APIKeys.m
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

#import "NSString+APIKeys.h"

@implementation NSString (APIKeys)

#pragma mark - General

+ (NSString *)userKey {
  return @"user";
}

+ (NSString *)sdkVersionKey {
  return @"sdkVersion";
}

+ (NSString *)publisherKey {
  return @"publisher";
}

+ (NSString *)profileIdKey {
  return @"profileId";
}

#pragma mark - Publisher

+ (NSString *)bundleIdKey {
  return @"bundleId";
}

+ (NSString *)cpIdKey {
  return @"cpId";
}

#pragma mark - User

+ (NSString *)userAgentKey {
  return @"userAgent";
}

+ (NSString *)deviceIdKey {
  return @"deviceId";
}

+ (NSString *)deviceOsKey {
  return @"deviceOs";
}

+ (NSString *)deviceModelKey {
  return @"deviceModel";
}

+ (NSString *)deviceIdTypeKey {
  return @"deviceIdType";
}

+ (NSString *)deviceIdTypeValue {
  return @"IDFA";
}

#pragma mark - GDPR

+ (NSString *)gdprConsentKey {
  return @"gdprConsent";
}

+ (NSString *)gdprAppliesKey {
  return @"gdprApplies";
}

+ (NSString *)gdprVersionKey {
  return @"version";
}

+ (NSString *)gdprConsentDataKey {
  return @"consentData";
}

#pragma mark - US privacy

+ (NSString *)uspCriteoOptout {
  return @"uspOptout";
}

+ (NSString *)uspIabKey {
  return @"uspIab";
}

+ (NSString *)mopubConsent {
  return @"mopubConsent";
}

@end
