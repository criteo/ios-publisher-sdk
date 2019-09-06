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
@property (readonly, nonatomic) CGSize size;
@property (readonly) NSUInteger hash;
@property (readonly, nonatomic) BOOL isValid;
@property (copy, readonly, nonatomic) NSString *cdbSize;

- (BOOL) isEqual:(id) object;

- (instancetype) initWithAdUnitId:(NSString *) adUnitId
                            width:(CGFloat) width
                           height:(CGFloat) height;

- (instancetype) initWithAdUnitId:(NSString *) adUnitId
                             size:(CGSize) size
NS_DESIGNATED_INITIALIZER;

- (instancetype) init NS_UNAVAILABLE;

- (instancetype) copyWithZone:(nullable NSZone *)zone;

@end
NS_ASSUME_NONNULL_END

typedef NSArray<CR_CacheAdUnit *> CR_CacheAdUnitArray;
typedef NSMutableArray<CR_CacheAdUnit *> MutableCR_CacheAdUnitArray;

#endif /* CR_CacheAdUnit_h */
