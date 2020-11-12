//
//  CR_URLResolver.h
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

#import <Foundation/Foundation.h>

@class CR_DeviceInfo;

typedef NS_ENUM(NSInteger, CR_URLResolutionType) {
  CR_URLResolutionError,
  CR_URLResolutionStandardUrl,
  CR_URLResolutionAppStoreUrl,
};

NS_ASSUME_NONNULL_BEGIN

@interface CR_URLResolution : NSObject
@property(nonatomic, assign, readonly) CR_URLResolutionType type;
@property(nonatomic, readonly, nullable) NSURL *URL;
@end

typedef void (^CR_URLResolutionHandler)(CR_URLResolution *resolution);

@interface CR_URLResolver : NSObject

+ (void)resolveURL:(NSURL *)url
        deviceInfo:(CR_DeviceInfo *)deviceInfo
        resolution:(CR_URLResolutionHandler)resolution;
- (void)resolverURL:(NSURL *)url
         deviceInfo:(CR_DeviceInfo *)deviceInfo
         resolution:(CR_URLResolutionHandler)resolution;

+ (BOOL)isAppStoreURL:(NSURL *)URL;

@end

NS_ASSUME_NONNULL_END
