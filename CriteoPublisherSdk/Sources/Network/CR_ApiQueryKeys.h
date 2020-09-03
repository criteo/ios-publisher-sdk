//
//  CR_ApiQueryKeys.h
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

@interface CR_ApiQueryKeys : NSObject

@property(class, nonatomic, readonly) NSString *appId;
@property(class, nonatomic, readonly) NSString *bidSlots;
@property(class, nonatomic, readonly) NSString *bidSlotsCachedBidUsed;
@property(class, nonatomic, readonly) NSString *bidSlotsImpressionId;
@property(class, nonatomic, readonly) NSString *bidSlotsIsInterstitial;
@property(class, nonatomic, readonly) NSString *bidSlotsIsNative;
@property(class, nonatomic, readonly) NSString *bidSlotsPlacementId;
@property(class, nonatomic, readonly) NSString *bidSlotsSizes;
@property(class, nonatomic, readonly) NSString *bundleId;
@property(class, nonatomic, readonly) NSString *cdbCallEndElapsed;
@property(class, nonatomic, readonly) NSString *cdbCallStartElapsed;
@property(class, nonatomic, readonly) NSString *cpId;
@property(class, nonatomic, readonly) NSString *deviceModel;
@property(class, nonatomic, readonly) NSString *deviceIdType;
@property(class, nonatomic, readonly) NSString *deviceId;
@property(class, nonatomic, readonly) NSString *deviceIdValue;
@property(class, nonatomic, readonly) NSString *deviceOs;
@property(class, nonatomic, readonly) NSString *eventType;
@property(class, nonatomic, readonly) NSString *feedbackElapsed;
@property(class, nonatomic, readonly) NSString *feedbacks;
@property(class, nonatomic, readonly) NSString *gdpr;
@property(class, nonatomic, readonly) NSString *gdprApplies;
@property(class, nonatomic, readonly) NSString *gdprConsentData;
@property(class, nonatomic, readonly) NSString *gdprVersion;
@property(class, nonatomic, readonly) NSString *idfa;
@property(class, nonatomic, readonly) NSString *impId;
@property(class, nonatomic, readonly) NSString *isTimeout;
@property(class, nonatomic, readonly) NSString *isAppInstallCapable;
@property(class, nonatomic, readonly) NSString *limitedAdTracking;
@property(class, nonatomic, readonly) NSString *mopubConsent;
@property(class, nonatomic, readonly) NSString *profile_id;
@property(class, nonatomic, readonly) NSString *profileId;
@property(class, nonatomic, readonly) NSString *publisher;
@property(class, nonatomic, readonly) NSString *id;
@property(class, nonatomic, readonly) NSString *requestGroupId;
@property(class, nonatomic, readonly) NSString *sdkVersion;
@property(class, nonatomic, readonly) NSString *uspIab;
@property(class, nonatomic, readonly) NSString *user;
@property(class, nonatomic, readonly) NSString *userAgent;
@property(class, nonatomic, readonly) NSString *uspCriteoOptout;
@property(class, nonatomic, readonly) NSString *wrapperVersion;
@property(class, nonatomic, readonly) NSString *zoneId;

@end
