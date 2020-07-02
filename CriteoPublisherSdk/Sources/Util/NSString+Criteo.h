//
//  NSString+Criteo.h
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
