//
//  NSError+CRErrors.m
//  pubsdk
//
//  Created by Sneha Pathrose on 5/21/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "NSError+CRErrors.h"

static NSString *const errorDomain = @"com.criteo.pubsdk";

@implementation NSError (CRErrors)

+ (NSError *)CRErrors_errorWithCode:(CRErrorCodes)code {
    return [NSError CRErrors_errorWithCode:code
                      description:nil];
}

+ (NSError *)CRErrors_errorWithCode:(CRErrorCodes)code
               description:(NSString *)description {
    NSString *finalDescription = [NSError descriptionForCRErrorCode:code];
    if(description != nil) {
        finalDescription = [NSString stringWithFormat:@"%@ %@",[NSError descriptionForCRErrorCode:code],description];
    }
    return [NSError errorWithDomain:errorDomain
                               code:code
                           userInfo:@{@"Description": finalDescription}];
}

+ (NSString *)descriptionForCRErrorCode:(CRErrorCodes)code {
    switch(code) {
        case CRErrorCodeNoFill:
            return @"Ad request was successful but no ads were available.";
        case CRErrorCodeNetworkError:
            return @"Ad request was unsuccessful due to network error.";
        case CRErrorCodeInvalidRequest:
            return @"Ad request is invalid.";
        case CRErrorCodeInternalError:
            return @"Ad request has failed due to an internal error.";
        case CRErrorCodeInvalidParameter:
            return @"Ad request has an invalid parameter.";
        default:
            return @"An error has occured.";
    }
}

@end
