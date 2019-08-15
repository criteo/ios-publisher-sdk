//
//  CRInterstitialAdUnit.h
//  CriteoPublisherSdk
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CRAdUnit.h"

NS_ASSUME_NONNULL_BEGIN

@interface CRInterstitialAdUnit : CRAdUnit

- (instancetype)initWithAdUnitId:(NSString *)adUnitId;

- (NSUInteger) hash;
- (BOOL) isEqual:(id)object;
- (BOOL) isEqualToInterstitialAdUnit:(CRInterstitialAdUnit *)adUnit;

@end

NS_ASSUME_NONNULL_END
