//
//  CRCustomEvent.m
//  CriteoGoogleAdapter
//
//  Copyright © 2018-2022 Criteo. All rights reserved.
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

#import "CRCustomEvent.h"
@import CriteoPublisherSdk;

@implementation CRCustomEvent
+ (GADVersionNumber)adSDKVersion {
  NSArray *versionComponents = [CRITEO_PUBLISHER_SDK_VERSION componentsSeparatedByString:@"."];
  GADVersionNumber version = {0};
  if (versionComponents.count >= 3) {
    version.majorVersion = [versionComponents[0] integerValue];
    version.minorVersion = [versionComponents[1] integerValue];
    version.patchVersion = [versionComponents[2] integerValue];
  }
  return version;
}

+ (GADVersionNumber)adapterVersion {
  return [CRCustomEvent adSDKVersion];
}

+ (nullable Class<GADAdNetworkExtras>)networkExtrasClass {
  return Nil;
}

+ (void)setUpWithConfiguration:(GADMediationServerConfiguration *)configuration
             completionHandler:(GADMediationAdapterSetUpCompletionBlock)completionHandler {
  completionHandler(nil);
}

- (NSError *)noFillError:(NSError *)error {
  return [NSError errorWithDomain:GADErrorDomain
                             code:GADErrorNoFill
                         userInfo:[NSDictionary dictionaryWithObject:error.description
                                                              forKey:NSLocalizedDescriptionKey]];
}

@end
