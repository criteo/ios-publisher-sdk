//
//  CR_HttpContent.m
//  pubsdk
//
//  Created by Romain Lofaso on 1/24/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "CR_HttpContent.h"

@implementation CR_HttpContent

- (instancetype)initWithUrl:(NSURL *)url
                       verb:(CR_HTTPVerb)verb
                requestBody:(NSDictionary *)requestBody
               responseBody:(NSData *)responseBody
                      error:(NSError *)error
                    counter:(unsigned)counter
{
    if (self = [super init]) {
        _url = [url copy];
        _verb = verb;
        _requestBody = [requestBody copy];
        _responseBody = [responseBody copy];
        _error = error;
        _counter = counter;
    }
    return self;
}

- (NSString *)description
{
    NSString *verbStr = self.verb == GET ? @"GET" : @"POST";
    NSMutableString *result = [[NSMutableString alloc] initWithFormat:
                               @"<%@: %p, url: %@, verb: %@ ",
                               NSStringFromClass([self class]), self, self.url, verbStr];
    if (self.requestBody.count > 0) {
        [result appendFormat:@"requestBody: %@ ", self.requestBody];
    }
    [result appendFormat:@"responseBody_size: %zd ", self.responseBody.length];
    if (self.error != nil) {
        [result appendFormat:@"error: %@ ", self.error];
    }
    [result appendFormat:@"responseBody: %zd ", self.responseBody.length];
    if (self.error != nil) {
        [result appendFormat:@"error: %@ ", self.error];
    }
    [result appendString:@">"];
    return result;
}

@end
