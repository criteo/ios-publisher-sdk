//
//  CR_ApiHandler.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 12/6/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "CR_ApiHandler.h"
#import "CR_Gdpr.h"
#import "Logging.h"
#import "NSArray+Criteo.h"
#import "CR_ThreadManager.h"

NSString * const CR_ApiHandlerBidSlotsIsInterstitialKey = @"interstitial";
NSString * const CR_ApiHandlerBidSlotsIsNativeKey = @"isNative";
NSString * const CR_ApiHandlerBidSlotsKey = @"slots";
NSString * const CR_ApiHandlerBidSlotsPlacementIdKey = @"placementId";
NSString * const CR_ApiHandlerBidSlotsSizesKey = @"sizes";
NSString * const CR_ApiHandlerBundleIdKey = @"bundleId";
NSString * const CR_ApiHandlerCpIdKey = @"cpId";
NSString * const CR_ApiHandlerDeviceModelKey = @"deviceModel";
NSString * const CR_ApiHandlerDeviceIdTypeKey = @"deviceIdType";
NSString * const CR_ApiHandlerDeviceIdKey = @"deviceId";
NSString * const CR_ApiHandlerDeviceIdTypeValue = @"IDFA";
NSString * const CR_ApiHandlerDeviceOsKey = @"deviceOs";
NSString * const CR_ApiHandlerGdprKey = @"gdrpConsent";
NSString * const CR_ApiHandlerGdprVersionKey = @"version";
NSString * const CR_ApiHandlerGdprConsentGivenKey = @"consentGiven";
NSString * const CR_ApiHandlerGdprConsentStringKey = @"consentData";
NSString * const CR_ApiHandlerGdprAppliedKey = @"gdprApplies";
NSString * const CR_ApiHandlerUspIabStringKey = @"uspIab";
NSString * const CR_ApiHandlerUserKey = @"user";
NSString * const CR_ApiHandlerUserAgentKey = @"userAgent";
NSString * const CR_ApiHandlerUspCriteoOptoutKey = @"uspOptout";
NSString * const CR_ApiHandlerMopubConsentKey = @"mopubConsent";
NSString * const CR_ApiHandlerSdkVersionKey = @"sdkVersion";
NSString * const CR_ApiHandlerProfileIdKey = @"profileId";
NSString * const CR_ApiHandlerPublisherKey = @"publisher";

static NSUInteger const maxAdUnitsPerCdbRequest = 8;

NSNumber *NumberFromGdprTcfVersion(CR_GdprTcfVersion version) {
    switch (version) {
        case CR_GdprTcfVersionUnknown: return nil;
        case CR_GdprTcfVersion1_1: return @1;
        case CR_GdprTcfVersion2_0: return @2;
    }
}

@interface CR_ApiHandler ()

@property (nonatomic, strong, readonly) CR_ThreadManager *threadManager;

@end

@implementation CR_ApiHandler

- (instancetype)init {
    NSAssert(false, @"Do not use this initializer");
    return [self initWithNetworkManager:nil bidFetchTracker:nil threadManager:nil];
}

- (instancetype) initWithNetworkManager:(CR_NetworkManager *)networkManager
                        bidFetchTracker:(CR_BidFetchTracker *)bidFetchTracker
                          threadManager:(CR_ThreadManager *)threadManager {
    if(self = [super init]) {
        _networkManager = networkManager;
        _bidFetchTracker = bidFetchTracker;
        _threadManager = threadManager;
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
    postBody[CR_ApiHandlerSdkVersionKey] = config.sdkVersion;
    postBody[CR_ApiHandlerProfileIdKey]  = config.profileId;


    NSMutableDictionary *userDict = [NSMutableDictionary new];
    userDict[CR_ApiHandlerDeviceModelKey]   = config.deviceModel;
    userDict[CR_ApiHandlerDeviceOsKey]      = config.deviceOs;
    userDict[CR_ApiHandlerDeviceIdKey]      = deviceInfo.deviceId;
    userDict[CR_ApiHandlerUserAgentKey]     = deviceInfo.userAgent;
    userDict[CR_ApiHandlerDeviceIdTypeKey]  = CR_ApiHandlerDeviceIdTypeValue;

    if (consent.usPrivacyIabConsentString.length > 0) {
        userDict[CR_ApiHandlerUspIabStringKey] = consent.usPrivacyIabConsentString;
    }
    if (consent.usPrivacyCriteoState == CR_CCPACriteoStateOptIn) {
        userDict[CR_ApiHandlerUspCriteoOptoutKey] = @NO;
    } else if (consent.usPrivacyCriteoState == CR_CCPACriteoStateOptOut) {
        userDict[CR_ApiHandlerUspCriteoOptoutKey] = @YES;
    } // else if unknown we add nothing.

    if (consent.mopubConsent.length > 0) {
        userDict[CR_ApiHandlerMopubConsentKey] = consent.mopubConsent;
    }
    postBody[CR_ApiHandlerUserKey] = userDict;

    NSMutableDictionary *publisher = [NSMutableDictionary new];
    publisher[CR_ApiHandlerBundleIdKey] = config.appId;
    publisher[CR_ApiHandlerCpIdKey]     = config.criteoPublisherId;
    postBody[CR_ApiHandlerPublisherKey] = publisher;

    CR_Gdpr *gdpr = consent.gdpr;
    const BOOL shouldAddGdpr =  (gdpr.tcfVersion != CR_GdprTcfVersionUnknown) &&
                                (gdpr.consentString != nil);
    if (shouldAddGdpr) {
        NSMutableDictionary *gdprDict = [NSMutableDictionary new];
        gdprDict[CR_ApiHandlerGdprConsentStringKey] = gdpr.consentString;
        gdprDict[CR_ApiHandlerGdprAppliedKey]       = @(gdpr.isApplied);
        gdprDict[CR_ApiHandlerGdprConsentGivenKey]  = @(gdpr.consentGivenToCriteo);
        gdprDict[CR_ApiHandlerGdprVersionKey]       = NumberFromGdprTcfVersion(gdpr.tcfVersion);
        postBody[CR_ApiHandlerGdprKey]              = gdprDict;
    }

    return postBody;
}

// Create the slots for the CDB request
- (NSArray *)slotsForRequest:(CR_CacheAdUnitArray *)adUnits {
    NSMutableArray *slots = [NSMutableArray new];
    for (CR_CacheAdUnit *adUnit in adUnits) {
        NSMutableDictionary *slotDict = [NSMutableDictionary new];
        slotDict[CR_ApiHandlerBidSlotsPlacementIdKey] = adUnit.adUnitId;
        slotDict[CR_ApiHandlerBidSlotsSizesKey] = @[adUnit.cdbSize];
        if(adUnit.adUnitType == CRAdUnitTypeNative) {
            slotDict[CR_ApiHandlerBidSlotsIsNativeKey] = @(YES);
        }
        else if(adUnit.adUnitType == CRAdUnitTypeInterstitial) {
            slotDict[CR_ApiHandlerBidSlotsIsInterstitialKey] = @(YES);
        }
        [slots addObject:slotDict];
    }
    return slots;
}

// Wrapper method to make the cdb call async
- (void)  callCdb:(CR_CacheAdUnitArray *)adUnits
          consent:(CR_DataProtectionConsent *)consent
           config:(CR_Config *)config
       deviceInfo:(CR_DeviceInfo *)deviceInfo
completionHandler:(CR_CdbCompletionHandler)completionHandler {
    [self.threadManager dispatchAsyncOnGlobalQueue:^{
        [self doCdbApiCall:adUnits
                   consent:consent
                    config:config
                deviceInfo:deviceInfo
         completionHandler:completionHandler];
    }];
}

// Method that makes the actual call to CDB
- (void)doCdbApiCall:(CR_CacheAdUnitArray *)adUnits
             consent:(CR_DataProtectionConsent *)consent
              config:(CR_Config *)config
          deviceInfo:(CR_DeviceInfo *)deviceInfo
   completionHandler:(CR_CdbCompletionHandler)completionHandler {

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
        postBody[CR_ApiHandlerBidSlotsKey] = [self slotsForRequest:adUnitChunk];

        // Send the request
        CLogInfo(@"[INFO][API_] CdbPostCall.start");
        [self.networkManager postToUrl:url postBody:postBody responseHandler:^(NSData *data, NSError *error) {
            CLogInfo(@"[INFO][API_] CdbPostCall.finished");
            if (error == nil) {
                if (data && completionHandler) {
                    CR_CdbResponse *cdbResponse = [CR_CdbResponse getCdbResponseForData:data receivedAt:[NSDate date]];
                    completionHandler(cdbResponse, nil);
                } else {
                    CLog(@"Error on post to CDB : response from CDB was nil");
                }
            } else {
                CLog(@"Error on post to CDB : %@", error);
                if(completionHandler) {
                    completionHandler(nil, error);
                }
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
