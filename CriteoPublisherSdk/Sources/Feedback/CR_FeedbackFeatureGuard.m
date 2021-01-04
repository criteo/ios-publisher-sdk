//
//  CR_FeedbackFeatureGuard.m
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

#import "CR_FeedbackFeatureGuard.h"

#import "CR_Config.h"
#import "CR_DataProtectionConsent.h"

@interface CR_FeedbackFeatureGuard ()

@property(nonatomic, strong, readonly) id<CR_FeedbackDelegate> realController;
@property(nonatomic, strong, readonly) CR_Config *config;
@property(nonatomic, strong, readonly) CR_DataProtectionConsent *consent;

@property(atomic, strong) id<CR_FeedbackDelegate> controller;

@end

@implementation CR_FeedbackFeatureGuard

#pragma mark - Lifecyle

- (instancetype)initWithController:(id<CR_FeedbackDelegate>)controller
                            config:(CR_Config *)config
                           consent:(CR_DataProtectionConsent *)consent {
  if (self = [super init]) {
    _realController = controller;
    _config = config;
    _consent = consent;

    [config addObserver:self forKeyPath:@"csmEnabled" options:0 context:nil];
    [consent addObserver:self forKeyPath:@"consentGiven" options:0 context:nil];
    [self updateController];
  }
  return self;
}

- (void)dealloc {
  [self.config removeObserver:self forKeyPath:@"csmEnabled"];
  [self.consent removeObserver:self forKeyPath:@"consentGiven"];
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

- (void)onBidCached:(CR_CdbBid *)bid {
  [self.controller onBidCached:bid];
}

- (void)onBidConsumed:(CR_CdbBid *)consumedBid {
  [self.controller onBidConsumed:consumedBid];
}

- (void)sendFeedbackBatch {
  [self.controller sendFeedbackBatch];
}

#pragma mark - Private

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if ([keyPath isEqual:@"csmEnabled"] || [keyPath isEqual:@"consentGiven"]) {
    [self updateController];
  } else {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
}

- (void)updateController {
  if (self.config.isCsmEnabled && self.consent.isConsentGiven) {
    self.controller = self.realController;
  } else {
    self.controller = nil;
  }
}

@end
