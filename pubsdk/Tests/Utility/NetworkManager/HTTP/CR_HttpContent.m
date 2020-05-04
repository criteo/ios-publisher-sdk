//
//  CR_HttpContent.m
//  pubsdk
//
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "CR_HttpContent.h"

NSString *NSStringFromHTTPVerb(CR_HTTPVerb verb) {
    switch (verb) {
        case GET: return @"GET";
        case POST: return @"POST";
    }
}

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

- (NSString *)description {
    NSDictionary *dict = @{
        @"url": self.url.absoluteString,
        @"verb": NSStringFromHTTPVerb(self.verb),
        @"requestBody" : (self.requestBody.count > 0) ? self.requestBody : NSNull.null,
        @"responseBody" : [self _formatedResponseBody] ?: NSNull.null,
        @"error" : self.error ?: NSNull.null
    };
    NSData *json = [NSJSONSerialization dataWithJSONObject:dict
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:NULL];

    return [[NSString alloc] initWithData:json
                                 encoding:NSUTF8StringEncoding];
}

- (NSString *)debugDescription {
    NSString *verbStr = NSStringFromHTTPVerb(self.verb);
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

#pragma mark - Private

- (id)_formatedResponseBody {
    if (self.responseBody.length == 0) {
        return nil;
    }

    NSError *error = NULL;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:self.responseBody
                                                         options:0
                                                           error:&error];
    return (error == nil) ? dict : self.responseBody;
}

@end
