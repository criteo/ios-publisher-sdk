//
//  NSString+CriteoUrl.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (CriteoUrl)

+ (nullable NSString *)cr_dfpCompatibleString:(nullable NSString *)string;
+ (nullable NSString *)cr_decodeDfpCompatibleString:(nullable NSString *)string;

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
