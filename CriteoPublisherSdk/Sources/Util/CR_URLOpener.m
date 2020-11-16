//
//  CR_URLOpener.m
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

#import "CR_URLOpener.h"

@implementation CR_URLOpener

- (void)openExternalURL:(NSURL *)url withCompletion:(CR_URLOpeningCompletion)completion {
  if (@available(iOS 10, *)) {
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:completion];
  } else if (completion) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    completion([[UIApplication sharedApplication] openURL:url]);
#pragma clang diagnostic pop
  }
}

@end
