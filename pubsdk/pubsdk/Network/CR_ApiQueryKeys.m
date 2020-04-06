//
//  CR_ApiQueryKeys.m
//  pubsdk
//
//  Created by Aleksandr Pakhmutov on 29/11/2019.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_ApiQueryKeys.h"


@implementation CR_ApiQueryKeys

+ (NSString *)appId                     { return @"appId"; }
+ (NSString *)bidSlots                  { return @"slots"; }
+ (NSString *)bidSlotsCachedBidUsed     { return @"cachedBidUsed"; }
+ (NSString *)bidSlotsImpressionId      { return @"impressionId"; }
+ (NSString *)bidSlotsIsInterstitial    { return @"interstitial"; }
+ (NSString *)bidSlotsIsNative          { return @"isNative"; }
+ (NSString *)bidSlotsPlacementId       { return @"placementId"; }
+ (NSString *)bidSlotsSizes             { return @"sizes"; }
+ (NSString *)bundleId                  { return @"bundleId"; }
+ (NSString *)cdbCallEndElapsed         { return @"cdbCallEndElapsed"; }
+ (NSString *)cdbCallStartElapsed       { return @"cdbCallStartElapsed"; }
+ (NSString *)cpId                      { return @"cpId"; }
+ (NSString *)deviceModel               { return @"deviceModel"; }
+ (NSString *)deviceIdType              { return @"deviceIdType"; }
+ (NSString *)deviceId                  { return @"deviceId"; }
+ (NSString *)deviceIdValue             { return @"IDFA"; }
+ (NSString *)deviceOs                  { return @"deviceOs"; }
+ (NSString *)eventType                 { return @"eventType"; }
+ (NSString *)feedbackElapsed           { return @"elapsed"; }
+ (NSString *)feedbacks                 { return @"feedbacks"; }
+ (NSString *)gdpr                      { return @"gdprConsent"; }
+ (NSString *)gdprApplies               { return @"gdprApplies"; }
+ (NSString *)gdprConsentData           { return @"consentData"; }
+ (NSString *)gdprVersion               { return @"version"; }
+ (NSString *)idfa                      { return @"idfa"; }
+ (NSString *)impId                     { return @"impId"; }
+ (NSString *)isTimeout                 { return @"isTimeout"; }
+ (NSString *)limitedAdTracking         { return @"limitedAdTracking"; }
+ (NSString *)mopubConsent              { return @"mopubConsent"; }
+ (NSString *)profileId                 { return @"profileId"; }
+ (NSString *)profile_id                { return @"profile_id"; }
+ (NSString *)publisher                 { return @"publisher"; }
+ (NSString *)requestGroupId            { return @"requestGroupId"; }
+ (NSString *)sdkVersion                { return @"sdkVersion"; }
+ (NSString *)uspIab                    { return @"uspIab"; }
+ (NSString *)user                      { return @"user"; }
+ (NSString *)userAgent                 { return @"userAgent"; }
+ (NSString *)uspCriteoOptout           { return @"uspOptout"; }
+ (NSString *)wrapperVersion            { return @"wrapper_version"; }

@end
