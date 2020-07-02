//
//  CR_NetworkWaiter.h
//  CriteoPublisherSdkTests
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

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT const NSTimeInterval CR_NetworkWaiterDefaultTimeout;

@class CR_NetworkCaptor;
@class CR_HttpContent;

typedef BOOL (^CR_HTTPResponseTester)(CR_HttpContent *httpContent);

@interface CR_NetworkWaiter : NSObject

@property(nonatomic, weak, readonly) CR_NetworkCaptor *networkCaptor;
@property(nonatomic, strong, readonly) NSArray<CR_HTTPResponseTester> *testers;
@property(nonatomic, assign) BOOL finishedRequestsIncluded;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNetworkCaptor:(CR_NetworkCaptor *)networkCaptor
                              testers:(NSArray<CR_HTTPResponseTester> *)testers
    NS_DESIGNATED_INITIALIZER;

- (BOOL)wait;
- (BOOL)waitWithTimeout:(NSTimeInterval)timeout;

@end

NS_ASSUME_NONNULL_END
