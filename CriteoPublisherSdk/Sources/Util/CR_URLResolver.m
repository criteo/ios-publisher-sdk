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
#import "Logging.h"
#import "CR_DeviceInfo.h"
#import "CR_URLRequest.h"

@interface CR_URLResolution ()
@property(nonatomic, strong) NSURL *URL;
+ (instancetype)resolutionWithType:(CR_URLResolutionType)type;
+ (instancetype)resolutionError:(NSError *)error;
@end

@interface CR_URLResolver () <NSURLSessionDataDelegate>
@property(nonatomic, strong, readonly) NSURLSession *urlSession;
@property(nonatomic, copy) CR_URLResolutionHandler resolution;
@end

@implementation CR_URLResolver

#pragma mark - Lifecycle

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
        resolution:(CR_URLResolutionHandler)resolution {
  CR_URLResolver *resolver = [[CR_URLResolver alloc] init];
  [resolver resolverURL:url deviceInfo:deviceInfo resolution:resolution];
}

- (void)resolverURL:(NSURL *)url
         deviceInfo:(CR_DeviceInfo *)deviceInfo
         resolution:(CR_URLResolutionHandler)resolution {
  self.resolution = resolution;
  CR_URLRequest *request = [CR_URLRequest requestWithURL:url deviceInfo:deviceInfo];
  NSURLSessionDataTask *task = [self.urlSession dataTaskWithRequest:request];
  [task resume];
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
    self.resolution([CR_URLResolution resolutionError:error]);
    return;
  }
  CR_URLResolution *resolution = [CR_URLResolution resolutionWithType:CR_URLResolutionStandardUrl];
  resolution.URL = task.currentRequest.URL;
  self.resolution(resolution);
}

#pragma mark - Redirection

- (BOOL)shouldRedirectTo:(NSURLRequest *)request {
  // FIXME: Detect app store URLs
  return YES;
}

@end

@implementation CR_URLResolution

- (instancetype)initWithType:(CR_URLResolutionType)type {
  if (self = [super init]) {
    _type = type;
  }
  return self;
}

+ (instancetype)resolutionWithType:(CR_URLResolutionType)type {
  return [[self alloc] initWithType:type];
}

+ (CR_URLResolution *)resolutionError:(NSError *)error {
  CLog(@"URL Resolution error %@", error.description);
  return [self resolutionWithType:CR_URLResolutionError];
}

@end
