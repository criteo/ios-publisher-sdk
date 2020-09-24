//
//  NSString+GDPRVendorConsent.h
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

@interface NSString (GDPR)

#pragma mark UserDefaults

@property(copy, nonatomic, class, readonly) NSString *gdprConsentStringUserDefaultsKeyTcf1_1;
@property(copy, nonatomic, class, readonly) NSString *gdprConsentStringUserDefaultsKeyTcf2_0;
@property(copy, nonatomic, class, readonly) NSString *gdprVendorConsentsUserDefaultsKeyTcf1_1;
@property(copy, nonatomic, class, readonly) NSString *gdprVendorConsentsUserDefaultsKeyTcf2_0;
@property(copy, nonatomic, class, readonly) NSString *gdprAppliesUserDefaultsKeyTcf1_1;
@property(copy, nonatomic, class, readonly) NSString *gdprAppliesUserDefaultsKeyTcf2_0;
@property(copy, nonatomic, class, readonly) NSString *gdprPurposeConsentsStringForTcf2_0;
@property(copy, nonatomic, class, readonly) NSString *gdprPublisherRestrictionsKeyFormatForTcf2_0;
@property(copy, nonatomic, class, readonly) NSString *gdprVendorConsentsStringForTcf2_0;

#pragma mark ConsentString

@property(copy, nonatomic, class, readonly) NSString *gdprConsentStringForTcf1_1;
@property(copy, nonatomic, class, readonly) NSString *gdprConsentStringDeniedForTcf1_1;
@property(copy, nonatomic, class, readonly) NSString *gdprConsentStringForTcf2_0;
@property(copy, nonatomic, class, readonly) NSString *gdprConsentStringDeniedForTcf2_0;

@end

NS_ASSUME_NONNULL_END
