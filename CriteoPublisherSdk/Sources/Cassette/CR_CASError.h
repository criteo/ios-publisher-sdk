//  Copyright 2016 LinkedIn Corporation
//  Licensed under the BSD 2-Clause License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/BSD-2-Clause
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and limitations under the License.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const CR_CASErrorDomain;
FOUNDATION_EXPORT const int CR_CASErrorCode;

typedef NS_ENUM(NSInteger, CR_CASErrorType) {
    CR_CASErrorFileInitialization
};

@interface CR_CASError : NSObject

+ (NSError *)createError:(CR_CASErrorType)type;
+ (BOOL)handleError:(nullable NSError *)casError error:(NSError * __autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
