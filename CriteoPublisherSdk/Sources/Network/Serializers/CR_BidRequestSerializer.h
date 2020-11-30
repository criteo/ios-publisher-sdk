//
//  CR_BidRequestSerializer.h
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

NS_ASSUME_NONNULL_BEGIN

@class CR_CdbRequest;
@class CR_Config;
@class CR_DataProtectionConsent;
@class CR_DeviceInfo;
@class CR_GdprSerializer;
@class CRContextData;
@class CR_UserDataHolder;
@class CR_InternalContextProvider;

// This class is semantically incoherent with CR_CdbRequest.
// TODO: Refine the design and the naming of CR_CdbRequest & CR_BidRequestSerializer.
@interface CR_BidRequestSerializer : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithGdprSerializer:(CR_GdprSerializer *)gdprSerializer
                        userDataHolder:(CR_UserDataHolder *)userDataHolder
               internalContextProvider:(CR_InternalContextProvider *)internalContextProvider
    NS_DESIGNATED_INITIALIZER;

- (NSURL *)urlWithConfig:(CR_Config *)config;

- (NSDictionary *)bodyWithCdbRequest:(CR_CdbRequest *)cdbRequest
                             consent:(CR_DataProtectionConsent *)consent
                              config:(CR_Config *)config
                          deviceInfo:(CR_DeviceInfo *)deviceInfo
                             context:(CRContextData *)contextData;

#pragma mark - Private but unit-tested (To be refactored)

- (NSArray *)slotsWithCdbRequest:(CR_CdbRequest *)cdbRequest;

@end

NS_ASSUME_NONNULL_END
