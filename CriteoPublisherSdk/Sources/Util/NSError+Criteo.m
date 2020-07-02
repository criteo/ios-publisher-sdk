//
//  NSError+Criteo.m
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

#import "NSError+Criteo.h"

static NSString *const errorDomain = @"com.criteo.sdk.publisher";

@implementation NSError (Criteo)

+ (NSError *)cr_errorWithCode:(CRErrorCode)code {
  return [NSError cr_errorWithCode:code description:nil];
}

+ (NSError *)cr_errorWithCode:(CRErrorCode)code description:(nullable NSString *)description {
  NSString *finalDescription = [NSError cr_descriptionForCode:code];
  if (description != nil) {
    finalDescription =
        [NSString stringWithFormat:@"%@ %@", [NSError cr_descriptionForCode:code], description];
  }
  return [NSError errorWithDomain:errorDomain
                             code:code
                         userInfo:@{NSLocalizedDescriptionKey : finalDescription}];
}

+ (NSString *)cr_descriptionForCode:(CRErrorCode)code {
  switch (code) {
    case CRErrorCodeNoFill:
      return @"Ad request succeeded but no ads are available.";
    case CRErrorCodeNetworkError:
      return @"Ad request failed due to network error.";
    case CRErrorCodeInvalidRequest:
      return @"Invalid ad request.";
    case CRErrorCodeInternalError:
      return @"Ad request failed due to an internal error.";
    case CRErrorCodeInvalidParameter:
      return @"Invalid ad request parameter.";
    default:
      return @"An unknown error occurred.";
  }
}

@end
