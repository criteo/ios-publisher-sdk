//
//  CR_URLResolver.m
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

#import "CR_URLResolver.h"
#import "CR_Logging.h"
#import "CR_DeviceInfo.h"
#import "CR_URLRequest.h"

@interface CR_URLResolution ()
@property(nonatomic, strong) NSURL *URL;
+ (instancetype)resolutionWithType:(CR_URLResolutionType)type URL:(NSURL *)URL;
+ (instancetype)resolutionError:(NSError *)error;
@end

@interface CR_URLResolver () <NSURLSessionDataDelegate>
@property(nonatomic, strong, readonly) NSURLSession *urlSession;

/** Ensure resolution handler is only called once, as resolution can occur on several events. */
@property(nonatomic, assign) BOOL resolved;
- (void)resolveWithResolution:(CR_URLResolution *)resolution;
@property(nonatomic, copy) CR_URLResolutionHandler resolutionHandler;

@end

@implementation CR_URLResolver

#pragma mark - Lifecycle

static NSArray *appStorePrefixes;

+ (void)initialize {
  [super initialize];
  appStorePrefixes = @[ @"apps.", @"itunes.", @"books.", @"music." ];
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _urlSession =
        [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration
                                      delegate:self
                                 delegateQueue:nil];
  }
  return self;
}

#pragma mark - Resolve

+ (void)resolveURL:(NSURL *)url
        deviceInfo:(CR_DeviceInfo *)deviceInfo
        resolution:(CR_URLResolutionHandler)resolutionHandler {
  CR_URLResolver *resolver = [[CR_URLResolver alloc] init];
  [resolver resolverURL:url deviceInfo:deviceInfo resolution:resolutionHandler];
}

- (void)resolverURL:(NSURL *)url
         deviceInfo:(CR_DeviceInfo *)deviceInfo
         resolution:(CR_URLResolutionHandler)resolutionHandler {
  self.resolutionHandler = resolutionHandler;
  if ([self tryResolveAppStoreURL:url]) {
    return;
  }

  CR_URLRequest *request = [CR_URLRequest requestWithURL:url deviceInfo:deviceInfo];
  NSURLSessionDataTask *task = [self.urlSession dataTaskWithRequest:request];
  [task resume];
}

- (BOOL)tryResolveAppStoreURL:(NSURL *)url {
  if ([CR_URLResolver isAppStoreURL:url]) {
    CR_URLResolution *resolution = [CR_URLResolution resolutionWithType:CR_URLResolutionAppStoreUrl
                                                                    URL:url];
    [self resolveWithResolution:resolution];
  }
  return self.resolved;
}

+ (BOOL)isAppStoreURL:(NSURL *)url {
  NSString *host = url.host;
  if (![host hasSuffix:@".apple.com"]) {
    return NO;
  }

  for (NSString *prefix in appStorePrefixes) {
    if ([host hasPrefix:prefix]) {
      return YES;
    }
  }

  return NO;
}

- (void)resolveWithResolution:(CR_URLResolution *)resolution {
  if (self.resolved) {
    return;
  }
  self.resolved = YES;
  self.resolutionHandler(resolution);
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
                          task:(NSURLSessionTask *)task
    willPerformHTTPRedirection:(NSHTTPURLResponse *)response
                    newRequest:(NSURLRequest *)request
             completionHandler:(void (^)(NSURLRequest *_Nullable))completionHandler {
  completionHandler([self shouldRedirectTo:request] ? request : nil);
}

- (void)URLSession:(NSURLSession *)session
                    task:(NSURLSessionTask *)task
    didCompleteWithError:(nullable NSError *)error {
  if (error != nil) {
    CR_URLResolution *resolution = [CR_URLResolution resolutionError:error];
    [self resolveWithResolution:resolution];
    return;
  }

  CR_URLResolution *resolution = [CR_URLResolution resolutionWithType:CR_URLResolutionStandardUrl
                                                                  URL:task.currentRequest.URL];
  [self resolveWithResolution:resolution];
}

#pragma mark - Redirection

- (BOOL)shouldRedirectTo:(NSURLRequest *)request {
  return ![self tryResolveAppStoreURL:request.URL];
}

@end

@implementation CR_URLResolution

- (instancetype)initWithType:(CR_URLResolutionType)type URL:(NSURL *)URL {
  if (self = [super init]) {
    _type = type;
    _URL = URL;
  }
  return self;
}

+ (instancetype)resolutionWithType:(CR_URLResolutionType)type URL:(NSURL *)URL {
  return [[self alloc] initWithType:type URL:URL];
}

+ (CR_URLResolution *)resolutionError:(NSError *)error {
  CRLogWarn(@"URLResolution", @"Failed resolving with error %@", error.description);
  return [self resolutionWithType:CR_URLResolutionError URL:nil];
}

@end
