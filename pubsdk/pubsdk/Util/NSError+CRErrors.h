//
//  NSError+CRErrors.h
//  pubsdk
//
//  Created by Sneha Pathrose on 5/21/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CRErrorCodes) {
    CRErrorCodeInternalError,
    CRErrorCodeNoFill,
    CRErrorCodeNetworkError,
    CRErrorCodeInvalidRequest,
    CRErrorCodeInvalidParameter,

    CRErrorCodeInvalidErrorCode //the last error code
};

@interface NSError (CRErrors)

+ (NSError *)CRErrors_errorWithCode:(CRErrorCodes)code;
+ (NSError *)CRErrors_errorWithCode:(CRErrorCodes)code
               description:(nullable NSString *)description;
+ (NSString *)descriptionForCRErrorCode:(CRErrorCodes)code;

@end

NS_ASSUME_NONNULL_END
