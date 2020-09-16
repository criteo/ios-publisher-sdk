//
//  CR_NetworkCaptor.m
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

#import "CR_NetworkCaptor.h"

#import "CR_DeviceInfo+Testing.h"
#import "MockWKWebView.h"
#import "CR_ThreadManager.h"

@interface CR_NetworkCaptor ()
@property(nonatomic, strong) NSMutableArray<CR_HttpContent *> *internalPendingRequests;
@property(nonatomic, strong) NSMutableArray<CR_HttpContent *> *internalFinishedRequests;
@property(nonatomic, assign) unsigned httpRequestCount;

@end

@implementation CR_NetworkCaptor

- (instancetype)initWithNetworkManager:(CR_NetworkManager *)networkManager {
  // FIXME EE-1228 This is a decorator and network manager should be a protocol. This would allow to
  // not
  //  mess up constructor like this.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
  self = [super initWithDeviceInfo:nil session:nil threadManager:nil];
#pragma clang diagnostic pop

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
  return [self.internalFinishedRequests
      sortedArrayUsingComparator:^NSComparisonResult(CR_HttpContent *_Nonnull obj1,
                                                     CR_HttpContent *_Nonnull obj2) {
        if (obj1.counter == obj2.counter) {
          return NSOrderedSame;
        } else if (obj1.counter < obj2.counter) {
          return NSOrderedAscending;
        } else {
          return NSOrderedDescending;
        }
      }];
}

- (NSArray<CR_HttpContent *> *)pendingRequests {
  return [self.internalPendingRequests copy];
}

- (void)getFromUrl:(NSURL *)url responseHandler:(CR_NMResponse)responseHandler {
  // Synchronized for avoiding multi-thread issue with the httpGetCount.
  @synchronized(self) {
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

    [self.networkManager getFromUrl:url
                    responseHandler:^(NSData *data, NSError *error) {
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
    responseHandler:(CR_NMResponse)responseHandler {
  // Synchronized for avoiding multi-thread issue with the httpPostCount.
  @synchronized(self) {
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
                     @synchronized(self) {
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

- (NSString *)description {
  return [[NSString alloc] initWithFormat:@"<%@: %p, pendingRequests: %@, finishedRequests: %@ >",
                                          NSStringFromClass([self class]), self,
                                          self.internalPendingRequests, self.finishedRequests];
}

@end
