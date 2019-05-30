//
//  CRCacheAdUnit.h
//  Criteo Publisher Sdk
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef CRCacheAdUnit_h
#define CRCacheAdUnit_h

#import <Foundation/Foundation.h>
#include <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN
@interface CRCacheAdUnit : NSObject <NSCopying>

@property (readonly, nonatomic) NSString *adUnitId;
@property (readonly, nonatomic) CGSize size;
@property (readonly) NSUInteger hash;

- (BOOL) isEqual:(id) object;

- (instancetype) initWithAdUnitId:(NSString *) adUnitId
                            width:(CGFloat) width
                           height:(CGFloat) height;

- (instancetype) initWithAdUnitId:(NSString *) adUnitId
                             size:(CGSize) size
NS_DESIGNATED_INITIALIZER;

- (instancetype) init NS_UNAVAILABLE;

- (instancetype) copyWithZone:(nullable NSZone *)zone;

- (NSString *) cdbSize;

@end
NS_ASSUME_NONNULL_END

#endif /* CRCacheAdUnit_h */
