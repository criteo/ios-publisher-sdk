//
//  CR_NetworkSessionPlayer.m
//  pubsdk
//
//  Created by Romain Lofaso on 12/17/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_NetworkSessionPlayer.h"
#import "CR_NetworkCaptor.h"
#import "CR_NetworkSessionReader.h"
#import "CR_DeviceInfo.h"
#import "MockWKWebView.h"

@interface CR_NetworkSessionPlayer ()

@property (nonatomic, copy, readonly) NSString *sessionIdentifier;
@property (nonatomic, strong, readonly) CR_NetworkSessionReader *reader;
@property (nonatomic, copy, readonly) NSArray<CR_HttpContent *> *session;
@property (nonatomic, strong, readonly) CR_NetworkManager *networkManager;

@end

@implementation CR_NetworkSessionPlayer

@synthesize session = _session;

- (instancetype)initWithNetworkManager:(nullable CR_NetworkManager *)networkManager
                     sessionIdentifier:(NSString *)identifier {
    MockWKWebView *webView = [[MockWKWebView alloc] init];
    CR_DeviceInfo *deviceInfo = [[CR_DeviceInfo alloc] initWithWKWebView:webView];
    if (self = [super initWithDeviceInfo:deviceInfo]) {
        _sessionIdentifier = identifier;
        _networkManager = networkManager;
        _reader = [[CR_NetworkSessionReader alloc] init];
        _session = nil; // lazy loading
    }
    return self;
}

- (void)getFromUrl:(NSURL *)url
   responseHandler:(CR_NMResponse)responseHandler {
    if (!responseHandler) return;

    CR_HttpContent *content = [self _contentWithUrl:url verb:GET body:nil];
    if (!content) {
        NSAssert(self.networkManager, @"Response not found and no network manager");
        [self.networkManager getFromUrl:url
                        responseHandler:responseHandler];
        return;
    }
    
    responseHandler(content.responseBody, content.error);
    NSLog(@"%@ has replayed %@ for %@", NSStringFromClass([CR_NetworkSessionPlayer class]), url, self.sessionIdentifier);
}

- (void) postToUrl:(NSURL *)url
          postBody:(NSDictionary *)postBody
   responseHandler:(CR_NMResponse)responseHandler {
    if (!responseHandler) return;

    CR_HttpContent *content = [self _contentWithUrl:url verb:POST body:postBody];
    if (!content) {
        NSAssert(self.networkManager, @"Response not found and no network manager");
        [self.networkManager postToUrl:url
                              postBody:postBody
                       responseHandler:responseHandler];
        return;
    }

    responseHandler(content.responseBody, content.error);
    NSLog(@"%@ has replayed %@ for %@", NSStringFromClass([CR_NetworkSessionPlayer class]), url, self.sessionIdentifier);
}

#pragma mark - Getters/Setters

- (void)setDelegate:(id<CR_NetworkManagerDelegate>)delegate {
    self.networkManager.delegate = delegate;
}

- (id<CR_NetworkManagerDelegate>)delegate {
    return self.networkManager.delegate;
}

- (NSArray<CR_HttpContent *> *)session {
    if (_session == nil) {
        _session = [self.reader sessionForKey:self.sessionIdentifier];
    }
    return _session;
}

#pragma mark - Private

- (CR_HttpContent *)_contentWithUrl:(NSURL *)url
                               verb:(CR_HTTPVerb)verb
                               body:(NSDictionary *)body {
    for (CR_HttpContent *content in self.session) {
        const BOOL sameUrl = [content.url isEqual:url];
        const BOOL sameVerb = content.verb == verb;
        const BOOL sameBody = ((body == nil) && (content.responseBody == nil)) || [content.responseBody isEqual:body];
        if (sameUrl && sameVerb && sameBody) {
            return content;
        }
    }
    return nil;
}

@end
