//
//  CRBannerAdUnit.h
//  CriteoPublisherSdk
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CRAdUnit.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CRBannerAdUnit : CRAdUnit

@property (readonly, nonatomic) CGSize size;

- (instancetype) initWithAdUnitId:(NSString *)adUnitId
                             size:(CGSize)size;

- (NSUInteger) hash;
- (BOOL) isEqual:(id)object;
- (BOOL) isEqualToBannerAdUnit:(CRBannerAdUnit *)adUnit;

@end

NS_ASSUME_NONNULL_END
