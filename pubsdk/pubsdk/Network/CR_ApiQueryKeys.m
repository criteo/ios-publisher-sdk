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
+ (NSString *)bidSlotsIsInterstitial    { return @"interstitial"; }
+ (NSString *)bidSlotsIsNative          { return @"isNative"; }
+ (NSString *)bidSlotsPlacementId       { return @"placementId"; }
+ (NSString *)bidSlotsSizes             { return @"sizes"; }
+ (NSString *)bundleId                  { return @"bundleId"; }
+ (NSString *)cpId                      { return @"cpId"; }
+ (NSString *)deviceModel               { return @"deviceModel"; }
+ (NSString *)deviceIdType              { return @"deviceIdType"; }
+ (NSString *)deviceId                  { return @"deviceId"; }
+ (NSString *)deviceIdValue             { return @"IDFA"; }
+ (NSString *)deviceOs                  { return @"deviceOs"; }
+ (NSString *)eventType                 { return @"eventType"; }
+ (NSString *)gdpr                      { return @"gdrpConsent"; }
+ (NSString *)gdprApplies               { return @"gdprApplies"; }
+ (NSString *)gdprConsentGiven          { return @"consentGiven"; }
+ (NSString *)gdprConsentData           { return @"consentData"; }
+ (NSString *)gdprVersion               { return @"version"; }
+ (NSString *)idfa                      { return @"idfa"; }
+ (NSString *)impId                     { return @"impId"; }
+ (NSString *)limitedAdTracking         { return @"limitedAdTracking"; }
+ (NSString *)mopubConsent              { return @"mopubConsent"; }
+ (NSString *)profileId                 { return @"profileId"; }
+ (NSString *)publisher                 { return @"publisher"; }
+ (NSString *)sdkVersion                { return @"sdkVersion"; }
+ (NSString *)uspIab                    { return @"uspIab"; }
+ (NSString *)user                      { return @"user"; }
+ (NSString *)userAgent                 { return @"userAgent"; }
+ (NSString *)uspCriteoOptout           { return @"uspOptout"; }

@end
