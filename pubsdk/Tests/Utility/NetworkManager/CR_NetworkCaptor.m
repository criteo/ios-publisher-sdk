//
//  CR_NetworkCaptor.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_NetworkCaptor.h"

#import "CR_DeviceInfo.h"
#import "MockWKWebView.h"
#import "CR_ThreadManager.h"

@interface CR_NetworkCaptor ()
@property (nonatomic, strong) NSMutableArray<CR_HttpContent *> *internalPendingRequests;
@property (nonatomic, strong) NSMutableArray<CR_HttpContent *> *internalFinishedRequests;
@property (nonatomic, assign) unsigned httpRequestCount;

@end

@implementation CR_NetworkCaptor

- (instancetype)initWithNetworkManager:(CR_NetworkManager *)networkManager
{
    MockWKWebView *webView = [[MockWKWebView alloc] init];
    CR_ThreadManager *threadManager = [[CR_ThreadManager alloc] init];
    CR_DeviceInfo *deviceInfo = [[CR_DeviceInfo alloc] initWithThreadManager:threadManager
                                                                     webView:webView];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    self = [super initWithDeviceInfo:deviceInfo session:session threadManager:threadManager];
    if (self) {
        _networkManager = networkManager;
        _internalPendingRequests = [[NSMutableArray alloc] init];
        _internalFinishedRequests = [[NSMutableArray alloc] init];
        _httpRequestCount = 0;
    }
    return self;
}

- (NSArray<CR_HttpContent *> *)allRequests {
    return [self.finishedRequests arrayByAddingObjectsFromArray:self.pendingRequests];
}

- (NSArray<CR_HttpContent *> *)finishedRequests {
    // Not efficitent but we don't care because this method is called only in tests.
    return [self.internalFinishedRequests sortedArrayUsingComparator:^NSComparisonResult(CR_HttpContent  *_Nonnull obj1, CR_HttpContent *_Nonnull obj2) {
        if (obj1.counter == obj2.counter) {
            return NSOrderedSame;
        } else if (obj1.counter < obj2.counter) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
}

- (NSArray<CR_HttpContent *> *)pendingRequests
{
    return [self.internalPendingRequests copy];
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
        [self.internalPendingRequests addObject:requestContent];

        [self.networkManager getFromUrl:url responseHandler:^(NSData *data, NSError *error) {
            CR_HttpContent *content = [[CR_HttpContent alloc] initWithUrl:url
                                                                     verb:GET
                                                              requestBody:nil
                                                             responseBody:data
                                                                    error:error
                                                                  counter:count];
            [self.internalFinishedRequests addObject:content];
            [self.internalPendingRequests removeObject:requestContent];
            if (responseHandler != nil) {
                responseHandler(data, error);
            }
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
        [self.internalPendingRequests addObject:requestContent];
        [self.networkManager postToUrl:url
                              postBody:postBody
                       responseHandler:^(NSData *data, NSError *error) {
                           @synchronized (self) {
                               CR_HttpContent *content = [[CR_HttpContent alloc] initWithUrl:url
                                                                                        verb:POST
                                                                                 requestBody:postBody
                                                                                responseBody:data
                                                                                       error:error
                                                                                     counter:count];
                               if (responseHandler != nil) {
                                   responseHandler(data, error);
                               }
                               [self.internalFinishedRequests addObject:content];
                               [self.internalPendingRequests removeObject:requestContent];
                               if (self.responseListener != nil) {
                                   self.responseListener(content);
                               }
                           }
                       }];
    }
}

- (void)clear {
    self.internalPendingRequests = [[NSMutableArray alloc] init];
    self.internalFinishedRequests = [[NSMutableArray alloc] init];
    self.httpRequestCount = 0;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:
            @"<%@: %p, pendingRequests: %@, finishedRequests: %@ >",
            NSStringFromClass([self class]), self, self.internalPendingRequests, self.finishedRequests];
}

@end
