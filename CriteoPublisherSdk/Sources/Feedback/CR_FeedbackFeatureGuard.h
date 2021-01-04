//
//  CR_FeedbackFeatureGuard.h
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

#ifndef CR_FeedbackFeatureGuard_H
#define CR_FeedbackFeatureGuard_H

#import <Foundation/Foundation.h>
#import "CR_FeedbackController.h"

@class CR_Config;
@class CR_DataProtectionConsent;

@interface CR_FeedbackFeatureGuard : NSObject <CR_FeedbackDelegate>

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithController:(id<CR_FeedbackDelegate>)controller
                            config:(CR_Config *)config
                           consent:(CR_DataProtectionConsent *)consent NS_DESIGNATED_INITIALIZER;

@end

#endif /* CR_FeedbackFeatureGuard_H */
