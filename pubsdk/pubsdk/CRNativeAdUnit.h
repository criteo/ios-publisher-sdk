//
//  CRNativeAdUnit.h
//  pubsdk
//
//  Created by Richard Clark on 9/10/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef CRNativeAdUnit_h
#define CRNativeAdUnit_h

#import "CRAdUnit.h"

NS_ASSUME_NONNULL_BEGIN

@interface CRNativeAdUnit : CRAdUnit

- (instancetype)initWithAdUnitId:(NSString *)adUnitId;

- (NSUInteger) hash;
- (BOOL)isEqual:(id)object;
- (BOOL)isEqualToNativeAdUnit:(CRNativeAdUnit *)adUnit;

@end

NS_ASSUME_NONNULL_END

#endif /* CRNativeAdUnit_h */
