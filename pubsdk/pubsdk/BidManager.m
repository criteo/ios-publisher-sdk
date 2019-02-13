//
//  BidManager.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 12/18/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import "BidManager.h"
#import "Logging.h"
#import "AppEvents.h"

@implementation BidManager
{
    ApiHandler      *apiHandler;
    CacheManager    *cacheManager;
    Config          *config;
    ConfigManager   *configManager;
    DeviceInfo      *deviceInfo;
    GdprUserConsent *gdprUserConsent;
    NetworkManager  *networkManager;
    AppEvents       *appEvents;
    NSTimeInterval  cdbTimeToNextCall;
}

// Properties
- (id<NetworkManagerDelegate>) networkMangerDelegate
{
    return self->networkManager.delegate;
}

- (void) setNetworkMangerDelegate:(id<NetworkManagerDelegate>)networkMangerDelegate
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

- (instancetype) initWithApiHandler:(ApiHandler*)apiHandler
                       cacheManager:(CacheManager*)cacheManager
                             config:(Config*)config
                      configManager:(ConfigManager*)configManager
                         deviceInfo:(DeviceInfo*)deviceInfo
                    gdprUserConsent:(GdprUserConsent*)gdprUserConsent
                     networkManager:(NetworkManager*)networkManager
                          appEvents:(AppEvents *)appEvents
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

- (void) setSlots: (NSArray<AdUnit*> *) slots {
    [cacheManager initSlots:slots];
}

- (NSDictionary *) getBids: (NSArray<AdUnit*> *) slots {
    NSMutableDictionary *bids = [[NSMutableDictionary alloc] init];
    for(AdUnit *slot in slots) {
        CdbBid *bid = [self getBid:slot];
        [bids setObject:bid forKey:slot];
    }
    return bids;
}

- (CdbBid *) getBid:(AdUnit *) slot {
    CdbBid *bid = [cacheManager getBid:slot];
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
        bid = [CdbBid emptyBid];
    }
    return bid;
}

// TODO: Figure out a way to test this
- (void) prefetchBid:(AdUnit *) slotId {
    if(!config) {
        CLog(@"Config hasn't been fetched. So no bids will be fetched.");
        return;
        // TODO : move kill switch logic out of bid manager
        // http://review.criteois.lan/#/c/461220/10/pubsdk/pubsdkTests/BidManagerTests.m
    } else if ([config killSwitch]) {
        CLog(@"killSwitch is engaged. No bid will be fetched.");
        return;
    }
    
    [self->apiHandler callCdb:slotId
                  gdprConsent:self->gdprUserConsent
                       config:self->config
                   deviceInfo:self->deviceInfo
         ahCdbResponseHandler:^(CdbResponse *cdbResponse) {
             if(cdbResponse.timeToNextCall) {
                 self->cdbTimeToNextCall = [[NSDate dateWithTimeIntervalSinceNow:cdbResponse.timeToNextCall]
                                            timeIntervalSinceReferenceDate];
             }
             for(CdbBid *bid in cdbResponse.cdbBids) {
                 [self->cacheManager setBid:bid forAdUnit:slotId];
             }
         }];
}

- (void) refreshConfig {
    if (config) {
        [configManager refreshConfig:config];
    }
}

- (void) addCriteoBidToRequest:(id) adRequest
                     forAdUnit:(AdUnit *) adUnit {
    if(!config) {
        CLog(@"Config hasn't been fetched. So no bids will be fetched.");
        return;
        // TODO : move kill switch logic out of bid manager
        // http://review.criteois.lan/#/c/461220/10/pubsdk/pubsdkTests/BidManagerTests.m
    } else if ([config killSwitch]) {
        CLog(@"killSwitch is engaged. No bid will be fetched.");
        return;
    }
    CdbBid *fetchedBid = [self getBid:adUnit];
    if ([fetchedBid isEmpty]) {
        return;
    }

    SEL dfpCustomTargeting = NSSelectorFromString(@"customTargeting");
    SEL dfpSetCustomTargeting = NSSelectorFromString(@"setCustomTargeting:");
    if([adRequest respondsToSelector:dfpCustomTargeting] && [adRequest respondsToSelector:dfpSetCustomTargeting]) {
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
        }
    }
}

@end
