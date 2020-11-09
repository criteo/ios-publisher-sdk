//
//  CR_URLRequest.m
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

#import "CR_URLRequest.h"

#import "CRConstants.h"
#import "CR_DeviceInfo.h"

@implementation CR_URLRequest

- (instancetype)initWithURL:(NSURL *)URL deviceInfo:(CR_DeviceInfo *)deviceInfo {
  self = [super initWithURL:URL
                cachePolicy:NSURLRequestReloadIgnoringCacheData
            timeoutInterval:CRITEO_DEFAULT_REQUEST_TIMEOUT_IN_SECONDS];
  if (self) {
    if (deviceInfo.userAgent) {
      [self setValue:deviceInfo.userAgent forHTTPHeaderField:@"User-Agent"];
    }
  }
  return self;
}

+ (instancetype)requestWithURL:(NSURL *)URL deviceInfo:(CR_DeviceInfo *)deviceInfo {
  return [[self alloc] initWithURL:URL deviceInfo:deviceInfo];
}

@end
