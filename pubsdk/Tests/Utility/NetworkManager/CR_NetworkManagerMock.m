//
//  CR_NetworkManagerMock.m
//  pubsdk
//
//  Created by Romain Lofaso on 12/11/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_NetworkManagerMock.h"
#import "CR_DeviceInfoMock.h"

NSString * const CR_NetworkManagerMockDefaultPostJsonResponse = @"{\"slots\":[{\"placementId\": \"adunitid_1\",\"cpm\":\"1.12\",\"currency\":\"EUR\",\"width\": 300,\"height\": 250, \"ttl\": 600, \"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />\"}]}";

@interface CR_NetworkManagerMock ()

@property (nonatomic, assign) NSUInteger numberOfPostCall;

@end

@implementation CR_NetworkManagerMock

- (instancetype)init {
    return [self initWithDeviceInfo:[[CR_DeviceInfoMock alloc] init]];
}

- (instancetype)initWithDeviceInfo:(CR_DeviceInfo *)deviceInfo {
    self = [super initWithDeviceInfo:deviceInfo];
    if (self) {
        _postResponseData = [CR_NetworkManagerMockDefaultPostJsonResponse dataUsingEncoding:NSUTF8StringEncoding];
        _postResponseError = nil;
        _respondingToPost = YES;
        _numberOfPostCall = 0;
    }
    return self;
}

- (void)getFromUrl:(NSURL *)url
   responseHandler:(CR_NMResponse)responseHandler {
}

- (void)postToUrl:(NSURL *)url
         postBody:(NSDictionary *)postBody
  responseHandler:(CR_NMResponse)responseHandler {
    self.numberOfPostCall += 1;
    self.lastPostBody = postBody;
    if (self.isRespondingToPost && responseHandler) {
        responseHandler(self.postResponseData, self.postResponseError);
    }
}


@end
