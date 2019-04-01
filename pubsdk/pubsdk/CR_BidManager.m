//
//  CR_BidManager.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 12/18/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import "CR_BidManager.h"
#import "Logging.h"
#import "CR_AppEvents.h"

@implementation CR_BidManager
{
    CR_ApiHandler      *apiHandler;
    CR_CacheManager    *cacheManager;
    CR_Config          *config;
    CR_ConfigManager   *configManager;
    CR_DeviceInfo      *deviceInfo;
    CR_GdprUserConsent *gdprUserConsent;
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
                             config:nil
                      configManager:nil
                         deviceInfo:nil
                    gdprUserConsent:nil
                     networkManager:nil
                          appEvents:nil
                     timeToNextCall:0];
}

- (instancetype) initWithApiHandler:(CR_ApiHandler*)apiHandler
                       cacheManager:(CR_CacheManager*)cacheManager
                             config:(CR_Config*)config
                      configManager:(CR_ConfigManager*)configManager
                         deviceInfo:(CR_DeviceInfo*)deviceInfo
                    gdprUserConsent:(CR_GdprUserConsent*)gdprUserConsent
                     networkManager:(CR_NetworkManager*)networkManager
                          appEvents:(CR_AppEvents *)appEvents
                     timeToNextCall:(NSTimeInterval)timeToNextCall
{
    if(self = [super init]) {
        self->apiHandler      = apiHandler;
        self->cacheManager    = cacheManager;
        self->config          = config;
        self->configManager   = configManager;
        self->deviceInfo      = deviceInfo;
        self->gdprUserConsent = gdprUserConsent;
        self->networkManager  = networkManager;
        self->appEvents       = appEvents;
        [self refreshConfig];
        self->cdbTimeToNextCall=timeToNextCall;
    }

    return self;
}

- (void) setSlots: (NSArray<CRAdUnit*> *) slots {
    [cacheManager initSlots:slots];
}

- (NSDictionary *) getBids: (NSArray<CRAdUnit*> *) slots {
    NSMutableDictionary *bids = [[NSMutableDictionary alloc] init];
    for(CRAdUnit *slot in slots) {
        CR_CdbBid *bid = [self getBid:slot];
        [bids setObject:bid forKey:slot];
    }
    return bids;
}

- (CR_CdbBid *) getBid:(CRAdUnit *) slot {
    CR_CdbBid *bid = [cacheManager getBid:slot];
    if(bid) {
        // Whether a valid bid was returned or not
        // fire call to prefetch here
        // only call cdb if time to next call has passed
        if([[NSDate date]timeIntervalSinceReferenceDate] >= self->cdbTimeToNextCall){
            [self prefetchBid:slot];
        }
    }
    // if the cache returns nil it means the key wasn't in the cache
    // return an empty bid
    else {
        bid = [CR_CdbBid emptyBid];
    }
    return bid;
}

// TODO: Figure out a way to test this
- (void) prefetchBid:(CRAdUnit *) slotId {
    if(!config) {
        CLog(@"Config hasn't been fetched. So no bids will be fetched.");
        return;
        // TODO : move kill switch logic out of bid manager
        // http://review.criteois.lan/#/c/461220/10/pubsdk/pubsdkTests/CR_BidManagerTests.m
    } else if ([config killSwitch]) {
        CLog(@"killSwitch is engaged. No bid will be fetched.");
        return;
    }
    
    [deviceInfo waitForUserAgent:^{
        [self->apiHandler callCdb:slotId
                      gdprConsent:self->gdprUserConsent
                           config:self->config
                       deviceInfo:self->deviceInfo
             ahCdbResponseHandler:^(CR_CdbResponse *cdbResponse) {
                 if(cdbResponse.timeToNextCall) {
                     self->cdbTimeToNextCall = [[NSDate dateWithTimeIntervalSinceNow:cdbResponse.timeToNextCall]
                                                timeIntervalSinceReferenceDate];
                 }
                 for(CR_CdbBid *bid in cdbResponse.cdbBids) {
                     [self->cacheManager setBid:bid forAdUnit:slotId];
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
                     forAdUnit:(CRAdUnit *) adUnit {
    if(!config) {
        CLog(@"Config hasn't been fetched. So no bids will be fetched.");
        return;
        // TODO : move kill switch logic out of bid manager
        // http://review.criteois.lan/#/c/461220/10/pubsdk/pubsdkTests/CR_BidManagerTests.m
    } else if ([config killSwitch]) {
        CLog(@"killSwitch is engaged. No bid will be fetched.");
        return;
    }
    CR_CdbBid *fetchedBid = [self getBid:adUnit];
    if ([fetchedBid isEmpty]) {
        return;
    }

    SEL dfpCustomTargeting = NSSelectorFromString(@"customTargeting");
    SEL dfpSetCustomTargeting = NSSelectorFromString(@"setCustomTargeting:");
    if([adRequest respondsToSelector:dfpCustomTargeting] && [adRequest respondsToSelector:dfpSetCustomTargeting]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id targeting = [adRequest performSelector:dfpCustomTargeting];

        if (targeting == nil) {
            targeting = [NSDictionary dictionary];
        }

        if ([targeting isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *customTargeting = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *) targeting];
            [customTargeting setObject:fetchedBid.cpm forKey:@"crt_cpm"];
            [customTargeting setObject:fetchedBid.dfpCompatibleDisplayUrl forKey:@"crt_displayUrl"];
            NSDictionary *updatedDictionary = [NSDictionary dictionaryWithDictionary:customTargeting];
            [adRequest performSelector:dfpSetCustomTargeting withObject:updatedDictionary];
#pragma clang diagnostic pop
        }
    }
}

@end
