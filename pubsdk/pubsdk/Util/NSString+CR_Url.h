//
//  NSString+CR_Url.h
//  pubsdk
//
//  Created by Paul Davis on 1/30/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (CR_Url)

+ (NSString *)dfpCompatibleString:(NSString*)string;
+ (NSString *)decodeDfpCompatibleString:(NSString *)string;
+ (NSString *)mopubCompatibleDisplayUrlForDisplayUrl:(NSString *)displayUrl;

/**
 Build an URL query params to append to a base URL.
 */
+ (NSString *)urlQueryParamsWithDictionary:(NSDictionary<NSString *, NSString *> *)dictionary;

/**
 Extract and return the URL query param as dictionary.
 */
- (NSDictionary<NSString *, NSString *> *)urlQueryParamsDictionary;

/**
Escape special characters for safe URL parameters.
*/
- (NSString *)urlEncode;

@end

NS_ASSUME_NONNULL_END
