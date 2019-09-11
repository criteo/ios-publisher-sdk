//
//  CR_CacheAdUnit.h
//  Criteo Publisher Sdk
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef CR_CacheAdUnit_h
#define CR_CacheAdUnit_h

#import <Foundation/Foundation.h>
#include <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN
@interface CR_CacheAdUnit : NSObject <NSCopying>

@property (copy, readonly, nonatomic) NSString *adUnitId;
@property (readonly, atomic) CGSize size;
@property (readonly) NSUInteger hash;
@property (readonly) BOOL isValid;
@property (copy, readonly, nonatomic) NSString *cdbSize;
@property (readonly) BOOL isNative;

- (BOOL) isEqual:(id) object;

- (instancetype) initWithAdUnitId:(NSString *) adUnitId
                            width:(CGFloat) width
                           height:(CGFloat) height;

- (instancetype) initWithAdUnitId:(NSString *) adUnitId
                             size:(CGSize) size;

- (instancetype) init NS_UNAVAILABLE;

- (instancetype)initWithAdUnitId:(NSString *)adUnitId
                            size:(CGSize)size
                        isNative:(BOOL)isNative
NS_DESIGNATED_INITIALIZER;

- (instancetype) copyWithZone:(nullable NSZone *)zone;

@end
NS_ASSUME_NONNULL_END

typedef NSArray<CR_CacheAdUnit *> CR_CacheAdUnitArray;
typedef NSMutableArray<CR_CacheAdUnit *> MutableCR_CacheAdUnitArray;

#endif /* CR_CacheAdUnit_h */
