//
//  NSString+Criteo.h
//  pubsdk
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef NSString_Criteo_h
#define NSString_Criteo_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Criteo)

+ (nullable NSString *)stringWithStringOrNil:(nullable NSString *)string;
+ (nullable NSString *)nonEmptyStringWithStringOrNil:(nullable NSString *)string;

@end

NS_ASSUME_NONNULL_END

#endif /* NSString_Criteo_h */
