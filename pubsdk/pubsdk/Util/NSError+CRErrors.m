//
//  NSError+CRErrors.m
//  pubsdk
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "NSError+CRErrors.h"

static NSString *const errorDomain = @"com.criteo.pubsdk";

@implementation NSError (CRErrors)

+ (NSError *)CRErrors_errorWithCode:(CRErrorCode)code {
    return [NSError CRErrors_errorWithCode:code
                      description:nil];
}

+ (NSError *)CRErrors_errorWithCode:(CRErrorCode)code
               description:(NSString *)description {
    NSString *finalDescription = [NSError descriptionForCRErrorCode:code];
    if(description != nil) {
        finalDescription = [NSString stringWithFormat:@"%@ %@",[NSError descriptionForCRErrorCode:code],description];
    }
    return [NSError errorWithDomain:errorDomain
                               code:code
                           userInfo:[NSDictionary dictionaryWithObject:finalDescription
                                                                forKey:NSLocalizedDescriptionKey]];
}

+ (NSString *)descriptionForCRErrorCode:(CRErrorCode)code {
    switch(code) {
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
            return @"An unknown error occured.";
    }
}

@end
