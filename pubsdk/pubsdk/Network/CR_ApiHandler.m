//
//  CR_ApiHandler.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 12/6/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "CR_ApiHandler.h"
#import "Logging.h"
#import "NSArray+Criteo.h"

// 8 is suggested by Jean Sebastien Faure as a reasonable group size for CDB calls
static NSUInteger const maxAdUnitsPerCdbRequest = 8;

@implementation CR_ApiHandler

- (instancetype) init
{
    NSAssert(false, @"Do not use this initializer");
    return [self initWithNetworkManager:nil bidFetchTracker:nil];
}

- (instancetype) initWithNetworkManager:(CR_NetworkManager *)networkManager bidFetchTracker:(CR_BidFetchTracker *)bidFetchTracker {
    if(self = [super init]) {
        self.networkManager = networkManager;
        self.bidFetchTracker = bidFetchTracker;
    }
    return self;
}

// Filter out bad ad units, or ones that are already being fetched. The ones that pass have their "BidFetchInProgress"
// flags set in bidFetchTracker.
- (CR_CacheAdUnitArray *)filterRequestAdUnitsAndSetProgressFlags:(CR_CacheAdUnitArray *)adUnits {
    MutableCR_CacheAdUnitArray *requestAdUnits = [MutableCR_CacheAdUnitArray new];
    for (CR_CacheAdUnit *adUnit in adUnits) {
        if (adUnit.isValid) {
            if ([self.bidFetchTracker trySetBidFetchInProgressForAdUnit:adUnit]) {
                [requestAdUnits addObject:adUnit];
            }
        } else {
            CLog(@"AdUnit is missing one of the following required values adUnitId = %@, width = %f, height = %f",
                 adUnit.adUnitId, adUnit.size.width, adUnit.size.height);
        }
    }
    return requestAdUnits;
}

// Create the postBody dictionary for the CDB request
- (NSMutableDictionary *)postBodyWithConsent:(CR_DataProtectionConsent *)consent
                                      config:(CR_Config *)config
                                  deviceInfo:(CR_DeviceInfo *)deviceInfo {
    NSMutableDictionary *postBody = [NSMutableDictionary new];
    postBody[@"sdkVersion"] = config.sdkVersion;
    postBody[@"profileId"]  = config.profileId;

    NSMutableDictionary *userDict = [NSMutableDictionary new];
    userDict[@"deviceModel"]  = config.deviceModel;
    userDict[@"deviceOs"]     = config.deviceOs;
    userDict[@"deviceId"]     = deviceInfo.deviceId;
    userDict[@"userAgent"]    = deviceInfo.userAgent;
    userDict[@"deviceIdType"] = @"IDFA";
    postBody[@"user"] = userDict;

    NSMutableDictionary *publisherDict = [NSMutableDictionary new];
    publisherDict[@"bundleId"] = config.appId;
    publisherDict[@"cpId"]     = config.criteoPublisherId;
    postBody[@"publisher"] = publisherDict;

    //iff gdpr consent value is set, pass it as a gdpr object. Else don't pass blank
    if (consent && consent.consentString) {
        NSMutableDictionary *gdprDict = [NSMutableDictionary new];
        gdprDict[@"consentData"]  = consent.consentString;
        gdprDict[@"gdprApplies"]  = @(consent.gdprApplies);
        gdprDict[@"consentGiven"] = @(consent.consentGiven);
        postBody[@"gdprConsent"]  = gdprDict;
    }

    return postBody;
}

// Create the slots for the CDB request
- (NSArray *)slotsForRequest:(CR_CacheAdUnitArray *)adUnits {
    NSMutableArray *slots = [NSMutableArray new];
    for (CR_CacheAdUnit *adUnit in adUnits) {
        NSMutableDictionary *slotDict = [NSMutableDictionary new];
        slotDict[@"placementId"] = adUnit.adUnitId;
        slotDict[@"sizes"] = @[adUnit.cdbSize];
        if(adUnit.adUnitType == CRAdUnitTypeNative) {
            slotDict[@"isNative"] = @(YES);
        }
        else if(adUnit.adUnitType == CRAdUnitTypeInterstitial) {
            slotDict[@"interstitial"] = @(YES);
        }
        [slots addObject:slotDict];
    }
    return slots;
}

// Wrapper method to make the cdb call async
- (void)        callCdb:(CR_CacheAdUnitArray *)adUnits
                consent:(CR_DataProtectionConsent *)consent
                 config:(CR_Config *)config
             deviceInfo:(CR_DeviceInfo *)deviceInfo
   ahCdbResponseHandler:(AHCdbResponse)ahCdbResponseHandler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self doCdbApiCall:adUnits
                   consent:consent
                    config:config
                deviceInfo:deviceInfo
      ahCdbResponseHandler:ahCdbResponseHandler];
    });
}

// Method that makes the actual call to CDB
- (void) doCdbApiCall:(CR_CacheAdUnitArray *)adUnits
              consent:(CR_DataProtectionConsent *)consent
               config:(CR_Config *)config
           deviceInfo:(CR_DeviceInfo *)deviceInfo
 ahCdbResponseHandler:(AHCdbResponse)ahCdbResponseHandler {

    CR_CacheAdUnitArray *requestAdUnits = [self filterRequestAdUnitsAndSetProgressFlags:adUnits];
    if (requestAdUnits.count == 0) {
        return;
    }
    NSArray<CR_CacheAdUnitArray *> *adUnitChunks = [requestAdUnits splitIntoChunks:maxAdUnitsPerCdbRequest];
    NSMutableDictionary *postBody = [self postBodyWithConsent:consent
                                                       config:config
                                                   deviceInfo:deviceInfo];
    NSString *query = [NSString stringWithFormat:@"profileId=%@", [config profileId]];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?%@", [config cdbUrl], [config path], query];
    NSURL *url = [NSURL URLWithString: urlString];

    for (CR_CacheAdUnitArray *adUnitChunk in adUnitChunks) {

        // Set up the request for this chunk
        postBody[@"slots"] = [self slotsForRequest:adUnitChunk];

        // Send the request
        CLogInfo(@"[INFO][API_] CdbPostCall.start");
        [self.networkManager postToUrl:url postBody:postBody responseHandler:^(NSData *data, NSError *error) {
            CLogInfo(@"[INFO][API_] CdbPostCall.finished");
            if (error == nil) {
                if (data && ahCdbResponseHandler) {
                    CR_CdbResponse *cdbResponse = [CR_CdbResponse getCdbResponseForData:data receivedAt:[NSDate date]];
                    ahCdbResponseHandler(cdbResponse);
                } else {
                    CLog(@"Error on post to CDB : response from CDB was nil");
                }
            } else {
                CLog(@"Error on post to CDB : %@", error);
            }
            for (CR_CacheAdUnit *adUnit in adUnitChunk) {
                [self.bidFetchTracker clearBidFetchInProgressForAdUnit:adUnit];
            }
        }];
    }
}

- (void) getConfig:(CR_Config *) config
   ahConfigHandler:(AHConfigResponse) ahConfigHandler {
    if(![config criteoPublisherId] || [config sdkVersion].length == 0 || [config appId].length == 0) {
        CLog(@"Config is is missing one of the following required values criteoPublisherId = %@, sdkVersion = %@, appId = %@", [config criteoPublisherId], [config sdkVersion], [config appId]);
        if(ahConfigHandler) {
            ahConfigHandler(nil);
        }
    }

    // TODO: Move the url + query building logic to CR_Config class
    NSString *query = [NSString stringWithFormat:@"cpId=%@&sdkVersion=%@&appId=%@", [config criteoPublisherId], [config sdkVersion], [config appId]];
    NSString *urlString = [NSString stringWithFormat:@"%@?%@", config.configUrl, query];
    NSURL *url = [NSURL URLWithString: urlString];
    CLogInfo(@"[INFO][API_] ConfigGetCall.start");
    [self.networkManager getFromUrl:url responseHandler:^(NSData *data, NSError *error) {
        CLogInfo(@"[INFO][API_] ConfigGetCall.finished");
        if(error == nil) {
            if(data && ahConfigHandler) {
                NSDictionary *configValues = [CR_Config getConfigValuesFromData:data];
                ahConfigHandler(configValues);
            } else {
                CLog(@"Error on get from Config: response from Config was nil");
            }
        } else {
            CLog(@"Error on get from Config : %@", error);
        }
    }];
}

- (void) sendAppEvent:(NSString *)event
              consent:(CR_DataProtectionConsent *)consent
               config:(CR_Config *)config
           deviceInfo:(CR_DeviceInfo *)deviceInfo
       ahEventHandler:(AHAppEventsResponse)ahEventHandler {

    NSString *query = [NSString stringWithFormat:@"idfa=%@&eventType=%@&appId=%@&limitedAdTracking=%d"
                       , [deviceInfo deviceId], event, [config appId], ![consent isAdTrackingEnabled]];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?%@",[config appEventsUrl], [config appEventsSenderId], query];
    NSURL *url = [NSURL URLWithString: urlString];
    CLogInfo(@"[INFO][API_] AppEventGetCall.start");
    [self.networkManager getFromUrl:url responseHandler:^(NSData *data, NSError *error) {
        CLogInfo(@"[INFO][API_] AppEventGetCall.finished");
        if(error == nil) {
            if(data && ahEventHandler) {
                NSError *e = nil;
                NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
                if (!response) {
                    CLog(@"Error parsing app event JSON to AppEvents. Error was: %@" , e);
                } else {
                    ahEventHandler(response, [NSDate date]);
                }
            }
            else {
                CLog(@"Error on get from app events end point; either value is nil: (response: %@) or (ahEventHandler: %p)", data, ahEventHandler);
            }
        } else {
            CLog(@"Error on get from app events end point. Error was: %@", error);
        }
    }];
}
@end
