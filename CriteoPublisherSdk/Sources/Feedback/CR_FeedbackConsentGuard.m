//
//  CR_FeedbackConsentGuard.m
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

#import "CR_FeedbackConsentGuard.h"
#import "CR_DataProtectionConsent.h"
#import "CR_Gdpr.h"

@interface CR_FeedbackConsentGuard ()

@property(nonatomic, strong, readonly) id<CR_FeedbackDelegate> realController;
@property(nonatomic, strong, readonly) CR_DataProtectionConsent *consent;

@property(nonatomic, strong, readonly) id<CR_FeedbackDelegate> controller;

@end

@implementation CR_FeedbackConsentGuard

#pragma mark - Lifecycle

- (instancetype)initWithController:(id<CR_FeedbackDelegate>)controller
                           consent:(CR_DataProtectionConsent *)consent {
  if (self = [super init]) {
    _realController = controller;
    _consent = consent;
  }
  return self;
}

#pragma mark - CR_FeedbackDelegate

- (void)onCdbCallStarted:(CR_CdbRequest *)request {
  [self.controller onCdbCallStarted:request];
}

- (void)onCdbCallResponse:(CR_CdbResponse *)response fromRequest:(CR_CdbRequest *)request {
  [self.controller onCdbCallResponse:response fromRequest:request];
}

- (void)onCdbCallFailure:(NSError *)failure fromRequest:(CR_CdbRequest *)request {
  [self.controller onCdbCallFailure:failure fromRequest:request];
}

- (void)onBidConsumed:(CR_CdbBid *)consumedBid {
  [self.controller onBidConsumed:consumedBid];
}

- (void)sendFeedbackBatch {
  [self.controller sendFeedbackBatch];
}

#pragma mark - Private

/**
 * Checks if we are allowed to collect metrics regarding TCF v2 purposes:
 * - Purpose 1 - Store and/or access information on a device
 * - Purpose 7 - Measure ad performance
 * For more details: https://iabeurope.eu/iab-europe-transparency-consent-framework-policies/
 */
- (BOOL)hasFeedbackConsent {
  return [_consent.gdpr isConsentGivenForPurpose:1] && [_consent.gdpr isConsentGivenForPurpose:7];
}

- (id<CR_FeedbackDelegate>)controller {
  return self.realController && self.hasFeedbackConsent ? self.realController : nil;
}

@end
