//
//  CR_HttpContent.h
//  pubsdk
//
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    GET,
    POST
} CR_HTTPVerb;

NSString *NSStringFromHTTPVerb(CR_HTTPVerb verb);

/**
 Wrapper for the HTTP request and HTTP the response .
 */
@interface CR_HttpContent: NSObject

@property (nonatomic, copy, readonly) NSURL *url;
@property (nonatomic, assign, readonly) CR_HTTPVerb verb;
@property (nonatomic, copy, readonly) NSDictionary * requestBody;
@property (nonatomic, copy, readonly) NSData *responseBody;
@property (nonatomic, strong, readonly) NSError *error;
@property (nonatomic, assign, readonly) unsigned counter;

- (instancetype)initWithUrl:(NSURL *)url
                       verb:(CR_HTTPVerb)verb
                requestBody:(nullable NSDictionary *)requestBody
               responseBody:(nullable NSData *)responseBody
                      error:(nullable NSError *)error
                    counter:(unsigned)counter;

@end

NS_ASSUME_NONNULL_END
