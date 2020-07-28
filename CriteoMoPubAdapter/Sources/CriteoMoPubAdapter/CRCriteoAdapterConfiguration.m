//
//  CRCriteoAdapterConfiguration.m
//  CriteoMoPubAdapter
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

#import "CRCriteoAdapterConfiguration.h"
#import <CriteoPublisherSdk/CRConstants.h>

@implementation CRCriteoAdapterConfiguration

- (NSString *)adapterVersion {
  return CRITEO_PUBLISHER_SDK_VERSION;
}

- (NSString *)biddingToken {
  return nil;
}

- (NSString *)moPubNetworkName {
  return @"criteo";
}

- (NSString *)networkSdkVersion {
  return CRITEO_PUBLISHER_SDK_VERSION;
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> *)configuration
                                  complete:(void (^)(NSError *))complete {
  complete(nil);
}

@end
