//
//  CR_BidManager.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 12/18/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import "CR_BidManager.h"
#import "Logging.h"
#import "CR_BidManagerHelper.h"
#import "CR_TargetingKeys.h"
#import "NSString+CR_UrlEncoder.h"

@implementation CR_BidManager
{
    CR_ApiHandler      *apiHandler;
    CR_CacheManager    *cacheManager;
    CR_TokenCache      *tokenCache;
    CR_Config          *config;
    CR_ConfigManager   *configManager;
    CR_DeviceInfo      *deviceInfo;
    CR_DataProtectionConsent *consent;
    CR_NetworkManager  *networkManager;
    CR_AppEvents       *appEvents;
    NSTimeInterval     cdbTimeToNextCall;
}

// Properties
- (id<CR_NetworkManagerDelegate>) networkMangerDelegate
{
    return self->networkManager.delegate;
}

- (void) setNetworkMangerDelegate:(id<CR_NetworkManagerDelegate>)networkMangerDelegate
{
    self->networkManager.delegate = networkMangerDelegate;
}

- (instancetype) init {
    NSAssert(false, @"Do not use this initializer");
    return [self initWithApiHandler:nil
                       cacheManager:nil
                         tokenCache:nil
                             config:nil
                      configManager:nil
                         deviceInfo:nil
                            consent:nil
                     networkManager:nil
                          appEvents:nil
                     timeToNextCall:0];
}

- (instancetype) initWithApiHandler:(CR_ApiHandler*)apiHandler
                       cacheManager:(CR_CacheManager*)cacheManager
                         tokenCache:(CR_TokenCache *)tokenCache
                             config:(CR_Config*)config
                      configManager:(CR_ConfigManager*)configManager
                         deviceInfo:(CR_DeviceInfo*)deviceInfo
                            consent:(CR_DataProtectionConsent*)consent
                     networkManager:(CR_NetworkManager*)networkManager
                          appEvents:(CR_AppEvents *)appEvents
                     timeToNextCall:(NSTimeInterval)timeToNextCall
{
    if(self = [super init]) {
        self->apiHandler      = apiHandler;
        self->cacheManager    = cacheManager;
        self->tokenCache      = tokenCache;
        self->config          = config;
        self->configManager   = configManager;
        self->deviceInfo      = deviceInfo;
        self->consent = consent;
        self->networkManager  = networkManager;
        self->appEvents       = appEvents;
        self->cdbTimeToNextCall=timeToNextCall;
    }

    return self;
}

- (void)registerWithSlots:(CR_CacheAdUnitArray *)slots {
    [self refreshConfig];
    [appEvents sendLaunchEvent];
    [cacheManager initSlots:slots];
}

- (NSDictionary *) getBids: (CR_CacheAdUnitArray *) slots {
    NSMutableDictionary *bids = [[NSMutableDictionary alloc] init];
    for(CR_CacheAdUnit *slot in slots) {
        CR_CdbBid *bid = [self getBid:slot];
        bids[slot] = bid;
    }
    return bids;
}

- (CR_CdbBid *) getBid:(CR_CacheAdUnit *) slot {
    CR_CdbBid *bid = [cacheManager getBidForAdUnit:slot];
    if(bid) {
        if(bid.isExpired) {
            // immediately invalidate current cache entry if bid is expired
            [cacheManager removeBidForAdUnit:slot];
            // only call cdb if time to next call has passed
            if([[NSDate date]timeIntervalSinceReferenceDate] >= self->cdbTimeToNextCall){
                [self prefetchBid:slot];
            }
            return [CR_CdbBid emptyBid];
        } else if ([[bid cpm] floatValue] == 0 && [bid ttl] > 0) {
            // continue to do nothing as ttl hasn't expired on this silenced adUnit
            return [CR_CdbBid emptyBid];
        } else {
            // remove it from the cache and consume the good bid
            [cacheManager removeBidForAdUnit:slot];
            if([[NSDate date]timeIntervalSinceReferenceDate] >= self->cdbTimeToNextCall){
                [self prefetchBid:slot];
            }
            return bid;
        }
    }
    //if the bid is empty meaning prefetch failed, check if time to next call is elapsed
    else {
        //call cdb if time to next call has passed
        if([[NSDate date]timeIntervalSinceReferenceDate] >= self->cdbTimeToNextCall){
            [self prefetchBid:slot];
        }
    }
    return [CR_CdbBid emptyBid];
}

- (CR_TokenValue *)tokenValueForBidToken:(CRBidToken *)bidToken
                              adUnitType:(CRAdUnitType)adUnitType {
    return [tokenCache getValueForToken:bidToken
                             adUnitType:adUnitType];
}

// TODO: Figure out a way to test this

- (void) prefetchBid:(CR_CacheAdUnit *) adUnit {
    [self prefetchBids:@[adUnit]];
}

- (void) prefetchBids:(CR_CacheAdUnitArray *) adUnits {
    if(!config) {
        CLog(@"Config hasn't been fetched. So no bids will be fetched.");
        return;
        // TODO : move kill switch logic out of bid manager
        // http://review.criteois.lan/#/c/461220/10/pubsdk/pubsdkTests/CR_BidManagerTests.m
    } else if ([config killSwitch]) {
        CLog(@"killSwitch is engaged. No bid will be fetched.");
        return;
    }

    CLogInfo(@"[INFO][BIDS] Start prefetching for %@", adUnits);

    [deviceInfo waitForUserAgent:^{
        [self->apiHandler callCdb:adUnits
                          consent:self->consent
                           config:self->config
                       deviceInfo:self->deviceInfo
             ahCdbResponseHandler:^(CR_CdbResponse *cdbResponse) {
                 if(cdbResponse.timeToNextCall) {
                     self->cdbTimeToNextCall = [[NSDate dateWithTimeIntervalSinceNow:cdbResponse.timeToNextCall]
                                                timeIntervalSinceReferenceDate];
                 }
                 for(CR_CdbBid *bid in cdbResponse.cdbBids) {
                     [self->cacheManager setBid:bid];
                 }
             }];
    }];
}

- (void) refreshConfig {
    if (config) {
        [configManager refreshConfig:config];
    }
}

- (void) addCriteoBidToRequest:(id) adRequest
                     forAdUnit:(CR_CacheAdUnit *) adUnit {
    if(!config) {
        CLog(@"Config hasn't been fetched. So no bids will be fetched.");
        return;
        // TODO : move kill switch logic out of bid manager
        // http://review.criteois.lan/#/c/461220/10/pubsdk/pubsdkTests/CR_BidManagerTests.m
    } else if ([config killSwitch]) {
        CLog(@"killSwitch is engaged. No bid will be fetched.");
        return;
    }

    NSString *adRequestClassName = NSStringFromClass([adRequest class]);
    if([adRequestClassName isEqualToString:@"DFPRequest"] ||
       [adRequestClassName isEqualToString:@"DFPNRequest"] ||
       [adRequestClassName isEqualToString:@"DFPORequest"] ||
       [adRequestClassName isEqualToString:@"GADRequest"] ||
       [adRequestClassName isEqualToString:@"GADORequest"] ||
       [adRequestClassName isEqualToString:@"GADNRequest"]) {
        [self addCriteoBidToDfpRequest:adRequest forAdUnit:adUnit];
    } else if ([adRequestClassName isEqualToString:@"MPAdView"] ||
               [adRequestClassName isEqualToString:@"MPInterstitialAdController"]) {
        [self addCriteoBidToMopubRequest:adRequest forAdUnit:adUnit];
    } else if ([adRequest isKindOfClass:NSMutableDictionary.class]) {
        [self addCriteoBidToDictionary:adRequest forAdUnit:adUnit];
    }
}

- (void) addCriteoBidToDictionary:(NSMutableDictionary*)dictionary
                        forAdUnit:(CR_CacheAdUnit*)adUnit
{
    CR_CdbBid *fetchedBid = [self getBid:adUnit];
    if ([fetchedBid isEmpty]) {
        return;
    }

    dictionary[CR_TargetingKey_crtDisplayUrl] = fetchedBid.displayUrl;
    dictionary[CR_TargetingKey_crtCpm] = fetchedBid.cpm;
}

- (void) addCriteoBidToDfpRequest:(id) adRequest
                        forAdUnit:(CR_CacheAdUnit *) adUnit {
    CR_CdbBid *fetchedBid = [self getBid:adUnit];
    if ([fetchedBid isEmpty]) {
        return;
    }

    SEL dfpCustomTargeting = NSSelectorFromString(@"customTargeting");
    SEL dfpSetCustomTargeting = NSSelectorFromString(@"setCustomTargeting:");
    if([adRequest respondsToSelector:dfpCustomTargeting] && [adRequest respondsToSelector:dfpSetCustomTargeting]) {

// this is for ignoring warning related to performSelector: on unknown selectors
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id targeting = [adRequest performSelector:dfpCustomTargeting];

        if (targeting == nil) {
            targeting = [NSDictionary dictionary];
        }

        if ([targeting isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary* customTargeting = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *) targeting];
            customTargeting[CR_TargetingKey_crtCpm] = fetchedBid.cpm;
            if(adUnit.adUnitType == CRAdUnitTypeNative) {
                // bid will contain atleast one product, a privacy section and atleast one impression pixel
                CR_NativeAssets *nativeAssets = fetchedBid.nativeAssets;
                if(nativeAssets.products.count > 0) {
                    CR_NativeProduct *product = nativeAssets.products[0];
                    [self setDfpValue:product.title forKey:CR_TargetingKey_crtnTitle inDictionary:customTargeting];
                    [self setDfpValue:product.description forKey:CR_TargetingKey_crtnDesc inDictionary:customTargeting];
                    [self setDfpValue:product.price forKey:CR_TargetingKey_crtnPrice inDictionary:customTargeting];
                    [self setDfpValue:product.clickUrl forKey:CR_TargetingKey_crtnClickUrl inDictionary:customTargeting];
                    [self setDfpValue:product.callToAction forKey:CR_TargetingKey_crtnCta inDictionary:customTargeting];
                    [self setDfpValue:product.image.url forKey:CR_TargetingKey_crtnImageUrl inDictionary:customTargeting];
                }
                CR_NativeAdvertiser *advertiser = nativeAssets.advertiser;
                [self setDfpValue:advertiser.description forKey:CR_TargetingKey_crtnAdvName inDictionary:customTargeting];
                [self setDfpValue:advertiser.domain forKey:CR_TargetingKey_crtnAdvDomain inDictionary:customTargeting];
                [self setDfpValue:advertiser.logoImage.url forKey:CR_TargetingKey_crtnAdvLogoUrl inDictionary:customTargeting];
                [self setDfpValue:advertiser.logoClickUrl forKey:CR_TargetingKey_crtnAdvUrl inDictionary:customTargeting];

                CR_NativePrivacy *privacy = nativeAssets.privacy;
                [self setDfpValue:privacy.optoutClickUrl forKey:CR_TargetingKey_crtnPrUrl inDictionary:customTargeting];
                [self setDfpValue:privacy.optoutImageUrl forKey:CR_TargetingKey_crtnPrImageUrl inDictionary:customTargeting];
                [self setDfpValue:privacy.longLegalText forKey:CR_TargetingKey_crtnPrText inDictionary:customTargeting];
                customTargeting[CR_TargetingKey_crtnPixCount] =
                    [NSString stringWithFormat:@"%lu", (unsigned long) nativeAssets.impressionPixels.count];
                for(int i = 0; i < fetchedBid.nativeAssets.impressionPixels.count; i++) {
                    [self setDfpValue:fetchedBid.nativeAssets.impressionPixels[i]
                               forKey:[NSString stringWithFormat:@"%@%d", CR_TargetingKey_crtnPixUrl, i]
                         inDictionary:customTargeting];
                }
            }
            else {
                customTargeting[CR_TargetingKey_crtDfpDisplayUrl] = fetchedBid.dfpCompatibleDisplayUrl;
            }
            NSDictionary *updatedDictionary = [NSDictionary dictionaryWithDictionary:customTargeting];
            [adRequest performSelector:dfpSetCustomTargeting withObject:updatedDictionary];
#pragma clang diagnostic pop
        }
    }
}

- (void) addCriteoBidToMopubRequest:(id) adRequest
                          forAdUnit:(CR_CacheAdUnit *) adUnit {
    [CR_BidManagerHelper removeCriteoBidsFromMoPubRequest:adRequest];

    CR_CdbBid *fetchedBid = [self getBid:adUnit];
    if ([fetchedBid isEmpty]) {
        return;
    }

    SEL mopubKeywords = NSSelectorFromString(@"keywords");
    if([adRequest respondsToSelector:mopubKeywords]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id targeting = [adRequest performSelector:mopubKeywords];

        if (targeting == nil) {
            targeting = @"";
        }

        if ([targeting isKindOfClass:[NSString class]]) {
            NSMutableString *keywords = [[NSMutableString alloc] initWithString:targeting];
            if ([keywords length] > 0) {
                [keywords appendString:@","];
            }
            [keywords appendString:CR_TargetingKey_crtCpm];
            [keywords appendString:@":"];
            [keywords appendString:fetchedBid.cpm];
            [keywords appendString:@","];
            [keywords appendString:CR_TargetingKey_crtDisplayUrl];
            [keywords appendString:@":"];
            [keywords appendString:fetchedBid.mopubCompatibleDisplayUrl];
            [adRequest setValue:keywords forKey:@"keywords"];
#pragma clang diagnostic pop
        }
    }
}

- (CRBidResponse *)bidResponseForCacheAdUnit:(CR_CacheAdUnit *)cacheAdUnit
                                  adUnitType:(CRAdUnitType)adUnitType {
    CR_CdbBid *bid = [self getBid:cacheAdUnit];
    if([bid isEmpty]) {
        return [[CRBidResponse alloc]initWithPrice:0.0
                                        bidSuccess:NO
                                          bidToken:nil];
    }
    CRBidToken *bidToken = [tokenCache getTokenForBid:bid
                                           adUnitType:adUnitType];
    return [[CRBidResponse alloc] initWithPrice:[bid.cpm doubleValue]
                                     bidSuccess:YES
                                       bidToken:bidToken];
}

- (CR_Config *)config {
    return self->config;
}

- (void)setDfpValue:(NSString *)value
             forKey:(NSString *)key
       inDictionary:(NSMutableDictionary*)dict {
    if(value.length > 0) {
        dict[key] = [NSString dfpCompatibleString:value];
    }
}

@end
