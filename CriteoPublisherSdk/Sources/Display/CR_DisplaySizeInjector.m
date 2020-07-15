//
//  CR_DisplaySizeInjector.m
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

#import <CoreGraphics/CoreGraphics.h>
#import "CR_DisplaySizeInjector.h"
#import "CR_DeviceInfo.h"

@interface CR_DisplaySizeInjector ()

@property(strong, nonatomic, readonly) CR_DeviceInfo *deviceInfo;

@end

@implementation CR_DisplaySizeInjector

- (instancetype)initWithDeviceInfo:(CR_DeviceInfo *)deviceInfo {
  self = [super init];
  if (self) {
    _deviceInfo = deviceInfo;
  }
  return self;
}

- (NSString *)injectFullScreenSizeInDisplayUrl:(NSString *)displayUrl {
  CGSize size = self.deviceInfo.screenSize;
  return [self injectSize:size inDisplayUrl:displayUrl];
}

- (NSString *)injectSafeScreenSizeInDisplayUrl:(NSString *)displayUrl {
  CGSize size = self.deviceInfo.safeScreenSize;
  return [self injectSize:size inDisplayUrl:displayUrl];
}

#pragma - Private

- (NSString *)injectSize:(CGSize)size inDisplayUrl:(NSString *)displayUrl {
  BOOL hasNoQueryString = [displayUrl rangeOfString:@"?"].location == NSNotFound;

  NSString *separator;
  if (hasNoQueryString) {
    separator = @"?";
  } else {
    separator = @"&";
  }

  return [NSString stringWithFormat:@"%@%@wvw=%d&wvh=%d", displayUrl, separator, (int)size.width,
                                    (int)size.height];
}

@end