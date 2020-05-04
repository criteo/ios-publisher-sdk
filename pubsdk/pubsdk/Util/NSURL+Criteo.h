//
//  NSURL+Criteo.h
//  pubsdk
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef NSURL_Additions_h
#define NSURL_Additions_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (Criteo)

+ (nullable NSURL *)URLWithStringOrNil:(nullable NSString *)string;

@end

NS_ASSUME_NONNULL_END

#endif /* NSURL_Additions_h */
