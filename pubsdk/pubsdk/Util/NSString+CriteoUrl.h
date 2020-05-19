//
//  NSString+CriteoUrl.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (CriteoUrl)

+ (nullable NSString *)cr_dfpCompatibleString:(nullable NSString*)string;
+ (nullable NSString *)cr_decodeDfpCompatibleString:(nullable NSString *)string;
+ (nullable NSString *)cr_mopubCompatibleDisplayUrlForDisplayUrl:(nullable NSString *)displayUrl;

/**
 Build an URL query params to append to a base URL.
 */
+ (NSString *)cr_urlQueryParamsWithDictionary:(NSDictionary<NSString *, NSString *> *)dictionary;

/**
 Extract and return the URL query param as dictionary.
 */
- (nullable NSDictionary<NSString *, NSString *> *)cr_urlQueryParamsDictionary;

/**
Escape special characters for safe URL parameters.
*/
- (NSString *)cr_urlEncode;

@end

NS_ASSUME_NONNULL_END
