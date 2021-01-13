//
//  CR_NetworkManagerMock.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "CR_NetworkManagerMock.h"
#import "CR_DeviceInfoMock.h"

NSString *const CR_NetworkManagerMockDefaultPostJsonResponse =
    @"{\"slots\":[{\"placementId\": \"adunitid_1\",\"cpm\":\"1.12\",\"currency\":\"EUR\",\"width\": 300,\"height\": 250, \"ttl\": 600, \"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />\"}]}";

NSString *const CR_NetworkManagerMockDefaultGetJsonResponse = @"{\"throttleSec\":5}";

@interface CR_NetworkManagerMock ()

@property(nonatomic, assign) NSUInteger numberOfPostCall;
@property(nonatomic, assign) NSUInteger numberOfGetCall;

@end

@implementation CR_NetworkManagerMock

- (instancetype)init {
  return [self initWithDeviceInfo:[[CR_DeviceInfoMock alloc] init]];
}

- (instancetype)initWithDeviceInfo:(CR_DeviceInfo *)deviceInfo {
  self = [super initWithDeviceInfo:deviceInfo];
  if (self) {
    _postResponseData =
        [CR_NetworkManagerMockDefaultPostJsonResponse dataUsingEncoding:NSUTF8StringEncoding];
    _postResponseError = nil;
    _respondingToPost = YES;
    _numberOfPostCall = 0;
    _getResponseData =
        [CR_NetworkManagerMockDefaultGetJsonResponse dataUsingEncoding:NSUTF8StringEncoding];
    _getResponseError = nil;
    _respondingToGet = YES;
    _numberOfGetCall = 0;
  }
  return self;
}

- (void)getFromUrl:(NSURL *)url responseHandler:(CR_NMResponse)responseHandler {
  self.numberOfGetCall += 1;
  self.lastGetUrl = url;
  if (self.isRespondingToGet && responseHandler) {
    responseHandler(self.getResponseData, self.getResponseError);
  }
}

- (void)postToUrl:(NSURL *)url
               body:(id)body
         logWithTag:(NSString *_Nullable)logTag
    responseHandler:(nullable CR_NMResponse)responseHandler {
  if (self.postFilterUrl && ![self.postFilterUrl evaluateWithObject:url]) {
    return;
  }
  self.numberOfPostCall += 1;
  self.lastPostBody = body;
  if (self.isRespondingToPost && responseHandler) {
    responseHandler(self.postResponseData, self.postResponseError);
  }
}

@end
