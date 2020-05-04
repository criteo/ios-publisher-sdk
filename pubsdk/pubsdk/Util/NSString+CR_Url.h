//
//  NSString+CR_Url.h
//  pubsdk
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (CR_Url)

+ (nullable NSString *)dfpCompatibleString:(nullable NSString*)string;
+ (nullable NSString *)decodeDfpCompatibleString:(nullable NSString *)string;
+ (nullable NSString *)mopubCompatibleDisplayUrlForDisplayUrl:(nullable NSString *)displayUrl;

/**
 Build an URL query params to append to a base URL.
 */
+ (NSString *)urlQueryParamsWithDictionary:(NSDictionary<NSString *, NSString *> *)dictionary;

/**
 Extract and return the URL query param as dictionary.
 */
- (nullable NSDictionary<NSString *, NSString *> *)urlQueryParamsDictionary;

/**
Escape special characters for safe URL parameters.
*/
- (NSString *)urlEncode;

@end

NS_ASSUME_NONNULL_END
