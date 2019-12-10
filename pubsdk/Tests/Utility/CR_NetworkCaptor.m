//
//  CR_NetworkCaptor.m
//  pubsdkTests
//
//  Created by Romain Lofaso on 11/25/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_NetworkCaptor.h"

#import "CR_DeviceInfo.h"
#import "MockWKWebView.h"

@interface CR_NetworkCaptor ()
@property (nonatomic, strong) NSMutableArray<CR_HttpContent *> *waitingRequests;
/**
 History from the response perspective.
 */
@property (nonatomic, strong) NSMutableArray<CR_HttpContent *> *responseHistory;
@property (nonatomic, assign) unsigned httpRequestCount;

@end

@implementation CR_NetworkCaptor

- (instancetype)initWithNetworkManager:(CR_NetworkManager *)networkManager
{
    MockWKWebView *webView = [[MockWKWebView alloc] init];
    CR_DeviceInfo *deviceInfo = [[CR_DeviceInfo alloc] initWithWKWebView:webView];
    self = [super initWithDeviceInfo:deviceInfo];
    if (self) {
        _networkManager = networkManager;
        _waitingRequests = [[NSMutableArray alloc] init];
        _responseHistory = [[NSMutableArray alloc] init];
        _httpRequestCount = 0;
    }
    return self;
}

- (NSArray<CR_HttpContent *> *)history {
    // Not efficitent but we don't care because this method is called only in tests.
    return [self.responseHistory sortedArrayUsingComparator:^NSComparisonResult(CR_HttpContent  *_Nonnull obj1, CR_HttpContent *_Nonnull obj2) {
        if (obj1.counter == obj2.counter) {
            return NSOrderedSame;
        } else if (obj1.counter < obj2.counter) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
}

- (void)getFromUrl:(NSURL *)url
    responseHandler:(CR_NMResponse)responseHandler
{
    // Synchronized for avoiding multi-thread issue with the httpGetCount.
    @synchronized (self) {
        if (self.requestListener != nil) {
            self.requestListener(url, GET, nil);
        }
        self.httpRequestCount++;
        const unsigned count = self.httpRequestCount;
        CR_HttpContent *requestContent = [[CR_HttpContent alloc] initWithUrl:url
                                                                        verb:GET
                                                                 requestBody:nil
                                                                responseBody:nil
                                                                       error:nil
                                                                     counter:count];
        [self.waitingRequests addObject:requestContent];

        [self.networkManager getFromUrl:url responseHandler:^(NSData *data, NSError *error) {
            CR_HttpContent *content = [[CR_HttpContent alloc] initWithUrl:url
                                                                     verb:GET
                                                              requestBody:nil
                                                             responseBody:data
                                                                    error:error
                                                                  counter:count];
            if (responseHandler != nil) {
                responseHandler(data, error);
            }
            [self.responseHistory addObject:content];
            [self.waitingRequests removeObject:requestContent];
            if (self.responseListener != nil) {
                self.responseListener(content);
            }
        }];
    }
}

- (void)postToUrl:(NSURL *)url
         postBody:(NSDictionary *)postBody
  responseHandler:(CR_NMResponse)responseHandler
{
    // Synchronized for avoiding multi-thread issue with the httpPostCount.
    @synchronized (self) {
        if (self.requestListener != nil) {
            self.requestListener(url, POST, postBody);
        }
        self.httpRequestCount++;
        const unsigned count = self.httpRequestCount;
        CR_HttpContent *requestContent = [[CR_HttpContent alloc] initWithUrl:url
                                                                        verb:POST
                                                                 requestBody:postBody
                                                                responseBody:nil
                                                                       error:nil
                                                                     counter:count];
        [self.waitingRequests addObject:requestContent];
        [self.networkManager postToUrl:url
                              postBody:postBody
                       responseHandler:^(NSData *data, NSError *error) {
            CR_HttpContent *content = [[CR_HttpContent alloc] initWithUrl:url
                                                                     verb:POST
                                                              requestBody:postBody
                                                             responseBody:data
                                                                    error:error
                                                                  counter:count];
            if (responseHandler != nil) {
                responseHandler(data, error);
            }
            [self.responseHistory addObject:content];
            [self.waitingRequests removeObject:requestContent];
            if (self.responseListener != nil) {
                self.responseListener(content);
            }
        }];
    }
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:
            @"<%@: %p, waitingRequests: %@, responseHistory: %@ >",
            NSStringFromClass([self class]), self, self.waitingRequests, self.history];
}

@end

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
    [result appendFormat:@"responseBody_size: %lu ", self.responseBody.length];
    if (self.error != nil) {
        [result appendFormat:@"error: %@ ", self.error];
    }
    [result appendFormat:@"responseBody: %lu ", self.responseBody.length];
    if (self.error != nil) {
        [result appendFormat:@"error: %@ ", self.error];
    }
    [result appendString:@">"];
    return result;
}

@end
