//
//  CR_NetworkRecorder.m
//  pubsdk
//
//  Created by Romain Lofaso on 12/17/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_NetworkSessionRecorder.h"
#import "MockWKWebView.h"
#import "CR_DeviceInfo.h"
#import "CR_NetworkCaptor.h"
#import "CR_NetworkSessionWriter.h"

@interface CR_NetworkSessionRecorder ()

@property (nonatomic, strong) NSMutableArray *finishedRequests;
@property (nonatomic, strong) CR_NetworkSessionWriter *cache;

@end

@implementation CR_NetworkSessionRecorder

#pragma mark - Life cycle

- (instancetype)initWithNetworkManager:(CR_NetworkManager *)networkManager
                     sessionIdentifier:(NSString *)sessionIdentifier {
    MockWKWebView *webView = [[MockWKWebView alloc] init];
    CR_DeviceInfo *deviceInfo = [[CR_DeviceInfo alloc] initWithWKWebView:webView];
    self = [super initWithDeviceInfo:deviceInfo];
    if (self) {
        _networkManager = networkManager;
        _sessionIdentifier = sessionIdentifier;
        _finishedRequests = [[NSMutableArray alloc] init];
        _cache = [CR_NetworkSessionWriter defaultNetworkSessionCache];
    }
    return self;
}

#pragma mark - Getters/Setters

- (void)setDelegate:(id<CR_NetworkManagerDelegate>)delegate {
    self.networkManager.delegate = delegate;
}

- (id<CR_NetworkManagerDelegate>)delegate {
    return self.networkManager.delegate;
}

#pragma mark - NetworkManager methods

- (void)getFromUrl:(NSURL *)url
   responseHandler:(CR_NMResponse)responseHandler {
    [self.networkManager getFromUrl:url
                    responseHandler:^(NSData *data, NSError *error) {
         CR_HttpContent *content = [[CR_HttpContent alloc] initWithUrl:url
                                                                  verb:GET
                                                           requestBody:nil
                                                          responseBody:data
                                                                 error:error
                                                               counter:0];
        [self.finishedRequests addObject:content];
        if (responseHandler) {
            responseHandler(data, error);
        }
        [self flush];
    }];
}

- (void)postToUrl:(NSURL *)url
         postBody:(NSDictionary *)postBody
  responseHandler:(CR_NMResponse)responseHandler {
    [self.networkManager postToUrl:url
                          postBody:postBody
                   responseHandler:^(NSData *data, NSError *error) {
        CR_HttpContent *content = [[CR_HttpContent alloc] initWithUrl:url
                                                                 verb:POST
                                                          requestBody:postBody
                                                         responseBody:data
                                                                error:error
                                                              counter:0];
        [self.finishedRequests addObject:content];
        if (responseHandler) {
            responseHandler(data, error);
        }
        [self flush];
    }];
}

- (void)flush {
    // Dispatch for avoiding I/O perfomances impacting the tests
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.finishedRequests.count) {
            [self.cache setSession:[self.finishedRequests copy]
                            forKey:self.sessionIdentifier];
        }
    });
}

@end
