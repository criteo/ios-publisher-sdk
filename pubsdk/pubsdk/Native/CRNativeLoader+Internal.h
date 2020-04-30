//
//  CRNativeLoader+Internal.h
//  pubsdk
//
//  Created by Romain Lofaso on 2/10/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "CRNativeLoader.h"

NS_ASSUME_NONNULL_BEGIN

@interface CRNativeLoader ()

@property (nonatomic, strong, readonly) Criteo *criteo;
@property (nonatomic, strong, readonly) CRNativeAdUnit *adUnit;

- (instancetype)initWithAdUnit:(CRNativeAdUnit *)adUnit
                      delegate:(id <CRNativeDelegate>)delegate
                        criteo:(Criteo *)criteo;

@end

NS_ASSUME_NONNULL_END
