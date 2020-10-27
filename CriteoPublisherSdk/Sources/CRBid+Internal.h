//
//  CRBid+Internal.h
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

#ifndef CRBid_Internal_h
#define CRBid_Internal_h

#import <CriteoPublisherSdk/CRBid.h>

NS_ASSUME_NONNULL_BEGIN

@class CRAdUnit;
@class CR_CdbBid;
@class CR_NativeAssets;

@interface CRBid ()

@property(nonatomic, strong, readonly) CRAdUnit *adUnit;
@property(nonatomic, strong) CR_CdbBid *_Nullable cdbBid;

- (instancetype)initWithCdbBid:(CR_CdbBid *)cdbBid adUnit:(CRAdUnit *)adUnit;

- (CR_CdbBid *_Nullable)consume;

@end

NS_ASSUME_NONNULL_END

#endif /* CRBid_Internal_h */
