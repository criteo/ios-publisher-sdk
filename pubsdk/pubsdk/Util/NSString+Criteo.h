//
//  NSString+Criteo.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#ifndef NSString_Criteo_h
#define NSString_Criteo_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Criteo)

+ (nullable NSString *)cr_StringWithStringOrNil:(nullable NSString *)string;
+ (nullable NSString *)cr_nonEmptyStringWithStringOrNil:(nullable NSString *)string;

@end

NS_ASSUME_NONNULL_END

#endif /* NSString_Criteo_h */
