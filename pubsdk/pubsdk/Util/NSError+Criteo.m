//
//  NSError+Criteo.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "NSError+Criteo.h"

static NSString *const errorDomain = @"com.criteo.pubsdk";

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
