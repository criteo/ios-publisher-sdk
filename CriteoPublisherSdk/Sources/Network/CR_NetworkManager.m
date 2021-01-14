//
//  CR_NetworkManager.m
//  CriteoPublisherSdk
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

#import "CR_NetworkManager.h"
#import "CR_Logging.h"
#import "CR_ThreadManager.h"
#import "CR_URLRequest.h"

@interface CR_NetworkManager ()

@property(nonatomic, strong) CR_ThreadManager *threadManager;

@end

@implementation CR_NetworkManager {
  CR_DeviceInfo *deviceInfo;
  NSURLSession *session;
}

- (instancetype)init {
  NSAssert(false, @"Do not use this initializer");
  return [self initWithDeviceInfo:[[CR_DeviceInfo alloc] init]];
}

- (instancetype)initWithDeviceInfo:(CR_DeviceInfo *)deviceInfo {
  NSURLSession *session = [NSURLSession
      sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
  return [self initWithDeviceInfo:deviceInfo
                          session:session
                    threadManager:[[CR_ThreadManager alloc] init]];
}

- (instancetype)initWithDeviceInfo:(CR_DeviceInfo *)deviceInfo
                           session:(NSURLSession *)session
                     threadManager:(CR_ThreadManager *)threadManager {
  if (self = [super init]) {
    self->deviceInfo = deviceInfo;
    self->session = session;
    _threadManager = threadManager;
  }
  return self;
}

- (void)signalSentRequest:(NSURLRequest *)request {
  [self.threadManager dispatchAsyncOnMainQueue:^{
    if ([self.delegate respondsToSelector:@selector(networkManager:sentRequest:)]) {
      [self.delegate networkManager:self sentRequest:request];
    }
  }];
}

- (void)signalReceivedResponse:(NSURLResponse *)response
                      withData:(NSData *)data
                         error:(NSError *)error {
  [self.threadManager dispatchAsyncOnMainQueue:^{
    if ([self.delegate respondsToSelector:@selector(networkManager:
                                                  receivedResponse:withData:error:)]) {
      [self.delegate networkManager:self receivedResponse:response withData:data error:error];
    }
  }];
}

- (void)getFromUrl:(NSURL *)url responseHandler:(nullable CR_NMResponse)responseHandler {
  [deviceInfo waitForUserAgent:^{
    CR_URLRequest *request = [CR_URLRequest requestWithURL:url deviceInfo:self->deviceInfo];

    [self.threadManager runWithCompletionContext:^(CR_CompletionContext *context) {
      void (^completionHandler)(NSData *, NSURLResponse *, NSError *) =
          ^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
            [context executeBlock:^{
              @try {
                [self signalReceivedResponse:response withData:data error:error];
                if (!responseHandler) {
                  return;
                }
                if (error) {
                  // Add logging or metrics code here
                  responseHandler(nil, error);
                }
                if (response) {
                  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                  if (httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299) {
                    responseHandler(data, error);
                  } else {
                    // Add logging or metrics code here
                    // Need to figure out how to handle redirects
                  }
                }
              } @catch (NSException *exception) {
                CRLogException(@"Network", exception, @"Failed at GET request");
              }
            }];
          };
      NSURLSessionDataTask *task = [self->session dataTaskWithRequest:request
                                                    completionHandler:completionHandler];
      [task resume];
      [self signalSentRequest:request];
    }];
  }];
}

- (void)postToUrl:(NSURL *)url
               body:(id)body
         logWithTag:(NSString *_Nullable)logTag
    responseHandler:(nullable CR_NMResponse)responseHandler {
  CR_URLRequest *postRequest = [CR_URLRequest requestWithURL:url deviceInfo:deviceInfo];
  [postRequest setHTTPMethod:@"POST"];

  NSError *jsonError;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body
                                                     options:NSJSONWritingPrettyPrinted
                                                       error:&jsonError];

  [postRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [postRequest setHTTPBody:jsonData];
  if (logTag) {
    CRLogInfo(logTag, @"⬆️ Request: %@",
              [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
  }

  [self.threadManager runWithCompletionContext:^(CR_CompletionContext *context) {
    void (^completionHandler)(NSData *, NSURLResponse *, NSError *) =
        ^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
          [context executeBlock:^{
            @try {
              [self signalReceivedResponse:response withData:data error:error];
              if (!responseHandler) {
                return;
              }
              if (error) {
                if (logTag) {
                  CRLogInfo(logTag, @"⬇️ Error: %@", error);
                }
                responseHandler(nil, error);
              }
              if (response) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                // 204 is no content and needs to be handled on it's own
                if (httpResponse.statusCode == 204) {
                  responseHandler(nil, error);
                } else if (httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299) {
                  if (logTag) {
                    CRLogInfo(logTag, @"⬆️ Response: %@",
                              [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                  }
                  responseHandler(data, error);
                } else {
                  // Add logging or metrics code here
                }
              }
            } @catch (NSException *exception) {
              CRLogException(@"Network", exception, @"Failed at POST request");
            }
          }];
        };

    NSURLSessionDataTask *task = [self->session dataTaskWithRequest:postRequest
                                                  completionHandler:completionHandler];
    [task resume];
    [self signalSentRequest:postRequest];
  }];

  return;
}

- (void)postToUrl:(NSURL *)url
               body:(id)body
    responseHandler:(nullable CR_NMResponse)responseHandler {
  [self postToUrl:url body:body logWithTag:nil responseHandler:responseHandler];
}

@end
