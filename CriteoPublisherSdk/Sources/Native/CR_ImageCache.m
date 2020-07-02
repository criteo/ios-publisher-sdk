//
//  CR_ImageCache.m
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

#import <UIKit/UIKit.h>
#import "CR_ImageCache.h"

@interface CR_ImageRef : NSObject

@property(strong, nonatomic, readonly) UIImage *image;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithImage:(UIImage *)image NS_DESIGNATED_INITIALIZER;

@end

@implementation CR_ImageRef

- (instancetype)initWithImage:(UIImage *)image {
  if (self = [super init]) {
    _image = image;
  }
  return self;
}

@end

@interface CR_ImageCache ()

/**
 * Same images may appear several times for a same ad unit, or even on all ad unit (AdChoice icon).
 * To improve the UX and reduce the network and infra cost, a LRU or LFU cache should be internally
 * used to store references to downloaded images given their URI.
 *
 * It is not documented, but tests show that NSCache follow LRU order when evicting data, if data is
 * not hold. Here we're using an intermediate CR_ImageRef class, so nobody is holding the data
 * except the cache.
 */
@property(strong, nonatomic, readonly) NSCache<NSURL *, CR_ImageRef *> *cache;

@end

@implementation CR_ImageCache

- (instancetype)initWithSizeLimit:(NSUInteger)dataSizeLimit {
  if (self = [super init]) {
    _cache = [[NSCache alloc] init];
    _cache.totalCostLimit = dataSizeLimit;
  }
  return self;
}

- (void)setImage:(UIImage *)image forUrl:(NSURL *)url imageSize:(NSUInteger)size {
  CR_ImageRef *imageRef = [[CR_ImageRef alloc] initWithImage:image];
  [_cache setObject:imageRef forKey:url cost:size];
}

- (nullable UIImage *)imageForUrl:(NSURL *)url {
  CR_ImageRef *imageRef = [_cache objectForKey:url];
  return imageRef.image;
}

@end