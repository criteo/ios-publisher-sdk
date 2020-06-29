//
// Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_FeedbackFeatureGuard.h"
#import "CR_Config.h"

@interface CR_FeedbackFeatureGuard ()

@property(nonatomic, strong, readonly) CR_FeedbackController *realController;
@property(nonatomic, strong, readonly) CR_Config *config;

@property(atomic, strong) CR_FeedbackController *controller;

@end

@implementation CR_FeedbackFeatureGuard

- (void)dealloc {
  [self.config removeObserver:self forKeyPath:@"csmEnabled"];
}

- (instancetype)initWithController:(CR_FeedbackController *)controller config:(CR_Config *)config {
  if (self = [super init]) {
    _realController = controller;
    _config = config;

    [config addObserver:self forKeyPath:@"csmEnabled" options:0 context:nil];
    [self updateController];
  }
  return self;
}

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

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if ([keyPath isEqual:@"csmEnabled"]) {
    [self updateController];
  } else {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
}

- (void)updateController {
  if (self.config.isCsmEnabled) {
    self.controller = self.realController;
  } else {
    self.controller = nil;
  }
}

@end
