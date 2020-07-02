//
//  CR_Gdpr.h
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

/**
 Versions of the Transparency and Consent Framework (TCF).
 */
typedef NS_ENUM(NSInteger, CR_GdprTcfVersion) {
  CR_GdprTcfVersionUnknown = 0,
  CR_GdprTcfVersion1_1,
  CR_GdprTcfVersion2_0,
};

/**
 The IAB implementation of  the European General Data Protection Regulation (GDPR).

 Specification:
 https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework
 */
@interface CR_Gdpr : NSObject

/**
 TCF version that is found in the NSUserDefault.

 If two versions co-exist, we take the highest one.
 */
@property(nonatomic, readonly, assign) CR_GdprTcfVersion tcfVersion;

/**
 String specified by IAB that content all elements regarding the consent
 */
@property(copy, nonatomic, readonly, nullable) NSString *consentString;

/**
 @YES if the GDPR is applied on this device.
 */
@property(copy, nonatomic, readonly, nullable) NSNumber *applies;

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
