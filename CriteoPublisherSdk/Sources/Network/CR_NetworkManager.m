//
//  CR_NetworkManager.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_NetworkManager.h"
#import "Logging.h"
#import "CR_ThreadManager.h"

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
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    if (self->deviceInfo.userAgent) {
      [request setValue:self->deviceInfo.userAgent forHTTPHeaderField:@"User-Agent"];
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
                CLogException(exception);
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
           postBody:(NSDictionary *)postBody
    responseHandler:(nullable CR_NMResponse)responseHandler {
  NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:url];
  [postRequest setTimeoutInterval:30];
  [postRequest setHTTPMethod:@"POST"];

  if (deviceInfo.userAgent) {
    [postRequest setValue:deviceInfo.userAgent forHTTPHeaderField:@"User-Agent"];
  }

  NSError *jsonError;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postBody
                                                     options:NSJSONWritingPrettyPrinted
                                                       error:&jsonError];

  [postRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [postRequest setHTTPBody:jsonData];

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
                // 204 is no content and needs to be handled on it's own
                if (httpResponse.statusCode == 204) {
                  responseHandler(nil, error);
                } else if (httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299) {
                  responseHandler(data, error);
                } else {
                  // Add logging or metrics code here
                }
              }
            } @catch (NSException *exception) {
              CLogException(exception);
            }
          }];
        };
    NSURLSessionDataTask *task = [self->session dataTaskWithRequest:postRequest
                                                  completionHandler:completionHandler];
    [task resume];
    [self signalSentRequest:postRequest];
  }];
}

@end
