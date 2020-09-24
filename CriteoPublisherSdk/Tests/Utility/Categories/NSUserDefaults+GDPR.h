//
//  NSUserDefaults+GDPR.h
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

@interface NSUserDefaults (GDPR)

- (void)clearGdpr;

#pragma mark ConsentString

- (void)setGdprTcf1_1ConsentString:(NSString *)consentString;
- (void)setGdprTcf2_0ConsentString:(NSString *)consentString;

- (void)setGdprTcf1_1DefaultConsentString;
- (void)setGdprTcf2_0DefaultConsentString;

#pragma mark GdprApplies

// For the GDPR applies,
// We usually set "truthy" values (e.g @YES, @NO, @1, "0", "true").
// To be agnostic of the type we use NSObjects in parameters.

- (void)setGdprTcf1_1GdprApplies:(nullable NSObject *)gdprApplies;
- (void)setGdprTcf2_0GdprApplies:(nullable NSObject *)gdprApplies;

#pragma mark Purpose Consents

- (void)setGdprTcf2_0PurposeConsents:(nullable NSString *)purposeConsents;
- (void)setGdprTcf2_0PublisherRestrictions:(nullable NSObject *)publisherRestrictions
                                forPurpose:(NSUInteger)id;
- (void)setGdprTcf2_0VendorConsents:(nullable NSString *)vendorConsents;
- (void)setGdprTcf2_0VendorLegitimateInterests:(nullable NSString *)legitimateInterests;

@end

NS_ASSUME_NONNULL_END
