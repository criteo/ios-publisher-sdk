//
//  Criteo.h
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

#ifndef Criteo_h
#define Criteo_h

#import <Foundation/Foundation.h>
#import "CRAdUnit.h"
#import "CRBidResponse.h"

NS_ASSUME_NONNULL_BEGIN
@interface Criteo : NSObject

/* @abstract Use sharedInstance */
- (instancetype)init NS_UNAVAILABLE;
+ (nonnull instancetype)sharedCriteo;

/** @abstract Set a custom opt-out/opt-in with same behaviour as the CCPA (US Privacy). */
- (void)setUsPrivacyOptOut:(BOOL)usPrivacyOptOut;
/** @abstract Set the privacy consent string owned by the Mopub SDK. */
- (void)setMopubConsent:(NSString *)mopubConsent;

- (void)registerCriteoPublisherId:(NSString *)criteoPublisherId
                      withAdUnits:(NSArray<CRAdUnit *> *)adUnits;

- (void)setBidsForRequest:(id)request withAdUnit:(CRAdUnit *)adUnit;

- (CRBidResponse *)getBidResponseForAdUnit:(CRAdUnit *)adUnit;

@end
NS_ASSUME_NONNULL_END

#endif /* Criteo_h */
