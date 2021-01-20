//
//  Criteo+Internal.h
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

#ifndef Criteo_Internal_h
#define Criteo_Internal_h

#import "CR_NetworkManagerDelegate.h"
#import "CR_CacheAdUnit.h"
#import "CRAdUnit.h"
#import "CRAdUnit+Internal.h"
#import "Criteo.h"

@class CR_CdbBid;
@class CR_Config;
@class CR_ConfigManager;
@class CR_AppEvents;
@class CR_BidManager;
@class CR_ThreadManager;
@class CR_DependencyProvider;

typedef void (^CR_CdbBidResponseHandler)(CR_CdbBid *bid);

@interface Criteo ()

@property(strong, nonatomic, readonly) CR_AppEvents *appEvents;
@property(strong, nonatomic, readonly) CR_BidManager *bidManager;
@property(strong, nonatomic, readonly) CR_DependencyProvider *dependencyProvider;
@property(strong, nonatomic, readonly) CR_Config *config;
@property(strong, nonatomic, readonly) CR_ConfigManager *configManager;
@property(weak, nonatomic) id<CR_NetworkManagerDelegate> networkManagerDelegate;
@property(assign, nonatomic, getter=isRegistered) BOOL registered;
@property(strong, nonatomic, readonly) CR_ThreadManager *threadManager;

+ (void)resetSharedCriteo;

- (void)loadCdbBidForAdUnit:(CR_CacheAdUnit *)slot
                withContext:(CRContextData *)contextData
            responseHandler:(CR_CdbBidResponseHandler)responseHandler;

- (instancetype)initWithDependencyProvider:(CR_DependencyProvider *)dependencyProvider;
- (void)setup;

@end

#endif /* Criteo_Internal_h */
