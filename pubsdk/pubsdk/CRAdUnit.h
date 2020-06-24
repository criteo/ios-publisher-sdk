//
//  CRAdUnit.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CRAdUnit : NSObject

@property(readonly, nonatomic) NSString *adUnitId;

- (instancetype)init NS_UNAVAILABLE;

- (NSUInteger)hash;
- (BOOL)isEqual:(nullable id)object;
- (BOOL)isEqualToAdUnit:(CRAdUnit *)adUnit;

@end

NS_ASSUME_NONNULL_END
