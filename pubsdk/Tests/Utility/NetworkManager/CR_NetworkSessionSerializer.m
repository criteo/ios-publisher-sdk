//
//  CR_NetworkSessionSerializer.m
//  pubsdk
//
//  Created by Romain Lofaso on 12/17/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_NetworkSessionSerializer.h"
#import "CR_NetworkCaptor.h"

@implementation CR_NetworkSessionSerializer

- (NSString *)jsonWithSession:(NSArray<CR_HttpContent *> *)session {
    NSDictionary *dict = [self _dictionaryFromSession:session];
    NSError *error = nil;
    NSData *json = [NSJSONSerialization dataWithJSONObject:dict
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
    NSAssert(!error, @"Parsing JSON error %@ for session %@", error, session);
    NSString *jsonStr = [[NSString alloc] initWithData:json
                                              encoding:NSUTF8StringEncoding];
    return jsonStr;
}

- (NSArray<CR_HttpContent *> *)sessionWithJson:(NSString *)json {
    NSError *error = nil;
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *contentsDic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:(NSJSONReadingOptions)0
                                                                  error:&error];
    NSArray *contents = [self _sessionFromDictionary:contentsDic];
    return contents;
}

#pragma mark - Private method

- (NSString *)_httpContentsKey {
    NSString *key = [[NSString alloc] initWithFormat:@"%@s", NSStringFromClass([CR_HttpContent class])];
    return key;
}

#pragma mark Serialization

- (NSArray<CR_HttpContent *> *)_sessionFromDictionary:(NSDictionary *)dictionary {
    NSArray *serializeds = dictionary[[self _httpContentsKey]];
    NSMutableArray *deserializeds = [[NSMutableArray alloc] initWithCapacity:serializeds.count];
    for (NSDictionary *contentDict in serializeds) {
        CR_HttpContent *content = [self _contentWithDictionnary:contentDict];
        [deserializeds addObject:content];
    }
    return deserializeds;
}

- (CR_HttpContent *)_contentWithDictionnary:(NSDictionary *)dictionary {
    NSURL *url = [[NSURL alloc] initWithString:dictionary[NSStringFromSelector(@selector(url))]];
    CR_HTTPVerb verb = [dictionary[NSStringFromSelector(@selector(verb))] unsignedIntValue];
    unsigned counter = [dictionary[NSStringFromSelector(@selector(count))] unsignedIntValue];

    id requestBodyValue = dictionary[NSStringFromSelector(@selector(requestBody))];
    NSDictionary *requestBody = (requestBodyValue != NSNull.null) ? requestBodyValue : nil;

    id responseBodyValue = dictionary[NSStringFromSelector(@selector(responseBody))];
    NSData *responseBody = (responseBodyValue != NSNull.null) ? [responseBodyValue dataUsingEncoding:NSUTF8StringEncoding] : nil;

    id errorValue = dictionary[NSStringFromSelector(@selector(error))];
    NSError *error = (errorValue != NSNull.null) ? [self _errorWithDictionary:errorValue] : nil;

    CR_HttpContent *content = [[CR_HttpContent alloc] initWithUrl:url
                                                             verb:verb
                                                      requestBody:requestBody
                                                     responseBody:responseBody
                                                            error:error
                                                          counter:counter];
    return content;
}

- (NSError *)_errorWithDictionary:(NSDictionary *)dict {
    NSErrorDomain domain = dict[@"domain"];
    NSInteger code = [dict[@"code"] integerValue];
    return [[NSError alloc] initWithDomain:domain
                                      code:code
                                  userInfo:dict];
}

#pragma mark Deserialization

- (NSDictionary *)_dictionaryFromSession:(NSArray<CR_HttpContent *> *)session {
    NSMutableArray *serialized = [[NSMutableArray alloc] initWithCapacity:session.count];
    for (CR_HttpContent *content in session) {
        NSDictionary *dict = [self _dictionaryWithHttpContent:content];
        [serialized addObject:dict];
    }
    return @{ [self _httpContentsKey] : serialized };
}

- (NSDictionary *)_dictionaryWithHttpContent:(CR_HttpContent *)content {
    id err = content.error ? [self _dictionaryWithError:content.error] : NSNull.null;
    id response =  content.responseBody ? [[NSString alloc] initWithData:content.responseBody encoding:NSUTF8StringEncoding] : NSNull.null;
    return @{
        NSStringFromSelector(@selector(url)): [content.url absoluteString],
        NSStringFromSelector(@selector(verb)): @(content.verb),
        NSStringFromSelector(@selector(responseBody)): response,
        NSStringFromSelector(@selector(requestBody)): content.requestBody ?: NSNull.null,
        NSStringFromSelector(@selector(error)): err,
        NSStringFromSelector(@selector(count)): @(content.counter)
    };
}

- (NSDictionary *)_dictionaryWithError:(NSError *)error {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"domain"] = error.domain;
    dict[@"code"] = @(error.code);
    [error.userInfo enumerateKeysAndObjectsUsingBlock:^(NSErrorUserInfoKey  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            dict[key] = obj;
        }
    }];
    return dict;
}


@end
