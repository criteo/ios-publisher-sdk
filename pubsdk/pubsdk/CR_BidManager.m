//
//  CR_BidManager.m
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_BidManager.h"
#import "Logging.h"
#import "CR_FeedbackController.h"
#import "CR_HeaderBidding.h"
#import "CR_ThreadManager.h"

@interface CR_BidManager ()

@property (nonatomic, assign, readonly) BOOL isInSilenceMode;
@property (nonatomic, strong, readonly) CR_HeaderBidding *headerBidding;
@property (nonatomic, strong, readonly) id <CR_FeedbackDelegate> feedbackDelegate;

@end

@implementation CR_BidManager
{
    CR_ApiHandler      *apiHandler;
    CR_CacheManager    *cacheManager;
    CR_TokenCache      *tokenCache;
    CR_Config          *config;
    CR_ConfigManager   *configManager;
    CR_DeviceInfo      *deviceInfo;
    CR_NetworkManager  *networkManager;
    CR_AppEvents       *appEvents;
    NSTimeInterval     cdbTimeToNextCall;
}

// Properties
- (id<CR_NetworkManagerDelegate>) networkManagerDelegate
{
    return self->networkManager.delegate;
}

- (void) setNetworkManagerDelegate:(id<CR_NetworkManagerDelegate>)networkManagerDelegate
{
    self->networkManager.delegate = networkManagerDelegate;
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
                     timeToNextCall:0
                      headerBidding:nil
                   feedbackDelegate:nil
                      threadManager:nil];
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
                      headerBidding:(CR_HeaderBidding *)headerBidding
                    feedbackDelegate:(id <CR_FeedbackDelegate>)feedbackDelegate
                      threadManager:(CR_ThreadManager *)threadManager
{
    if(self = [super init]) {
        self->apiHandler      = apiHandler;
        self->cacheManager    = cacheManager;
        self->tokenCache      = tokenCache;
        self->config          = config;
        self->configManager   = configManager;
        self->deviceInfo      = deviceInfo;
        self->networkManager  = networkManager;
        self->appEvents       = appEvents;
        self->cdbTimeToNextCall=timeToNextCall;
        _consent              = consent;
        _feedbackDelegate = feedbackDelegate;
        _threadManager = threadManager;
        _headerBidding = headerBidding;
    }

    return self;
}

- (void)registerWithSlots:(CR_CacheAdUnitArray *)slots {
    [self refreshConfig];
    [appEvents registerForIosEvents];
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
    CR_CdbBid *bid = nil;
    @try {
        bid = [self unsafeGetBid:slot];
    }
    @catch (NSException *exception) {
        CLogException(exception);
    }
    return bid;
}

- (CR_CdbBid *)unsafeGetBid:(CR_CacheAdUnit *)slot {
    CR_CdbBid *bid = [cacheManager getBidForAdUnit:slot];
    CR_CdbBid *result = bid;
    BOOL didConsumeBid = NO;

    if (bid == nil || [bid isEqual:[CR_CdbBid emptyBid]]) {
        result = [CR_CdbBid emptyBid];
    }
    else if (bid.isExpired) {
        // immediately invalidate current cache entry if bid is expired
        [cacheManager removeBidForAdUnit:slot];
        didConsumeBid = YES;
        result = [CR_CdbBid emptyBid];
    }
    else if (bid.isInSilenceMode) {
        result = [CR_CdbBid emptyBid];
    }
    else {
        // remove it from the cache and consume the good bid
        [cacheManager removeBidForAdUnit:slot];
        didConsumeBid = YES;
    }

    [self.threadManager dispatchAsyncOnGlobalQueue:^{
        if (didConsumeBid) {
            [self.feedbackDelegate onBidConsumed:bid];
        }
        if (!self.isInSilenceMode && ((bid == nil) || bid.isRenewable)) {
            [self prefetchBid:slot];
        }
    }];

    return result;
}

- (BOOL)isInSilenceMode {
    return [[NSDate date] timeIntervalSinceReferenceDate] < self->cdbTimeToNextCall;
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
    if([self shouldCancelCdbCall]) {
        return;
    }

    CLogInfo(@"[INFO][BIDS] Start prefetching for %@", adUnits);

    [deviceInfo waitForUserAgent:^{
        [self->apiHandler callCdb:adUnits
                          consent:self.consent
                           config:self->config
                       deviceInfo:self->deviceInfo
                    beforeCdbCall:^(CR_CdbRequest *cdbRequest) {
                        [self beforeCdbCall:cdbRequest];
                    }
                completionHandler:^(CR_CdbRequest *cdbRequest, CR_CdbResponse *cdbResponse, NSError *error) {
                    if (error) {
                        [self handleError:error cdbRequest:cdbRequest];
                    } else if (cdbResponse) {
                        [self handleResponse:cdbResponse cdbRequest:cdbRequest];
                    }
                }];
    }];

    [self.feedbackDelegate sendFeedbackBatch];
}

- (void)beforeCdbCall:(CR_CdbRequest *)cdbRequest {
    [self.feedbackDelegate onCdbCallStarted:cdbRequest];
}

- (void)handleError:(NSError *)error cdbRequest:(CR_CdbRequest *)cdbRequest {
    [self.feedbackDelegate onCdbCallFailure:error fromRequest:cdbRequest];
}

- (void)handleResponse:(CR_CdbResponse *)cdbResponse cdbRequest:(CR_CdbRequest *)cdbRequest {
    [self updateTimeToNextCallIfProvided:cdbResponse];

    for (CR_CdbBid *bid in cdbResponse.cdbBids) {
        [self->cacheManager setBid:bid];
    }

    [self.feedbackDelegate onCdbCallResponse:cdbResponse fromRequest:cdbRequest];
}

- (BOOL)shouldCancelCdbCall {
    if (!config) {
        CLog(@"Config hasn't been fetched. So no bids will be fetched.");
        return YES;
        // TODO : move kill switch logic out of bid manager
        // https://review.crto.in/#/c/461220/10/pubsdk/pubsdkTests/CR_BidManagerTests.m
    } else if ([config killSwitch]) {
        CLog(@"killSwitch is engaged. No bid will be fetched.");
        return YES;
    }
    return NO;
}

- (void)updateTimeToNextCallIfProvided:(CR_CdbResponse *)cdbResponse {
    if(cdbResponse.timeToNextCall) {
        self->cdbTimeToNextCall = [[NSDate dateWithTimeIntervalSinceNow:cdbResponse.timeToNextCall]
            timeIntervalSinceReferenceDate];
    }
}

- (void) refreshConfig {
    if (config) {
        [configManager refreshConfig:config];
    }
}

- (void) addCriteoBidToRequest:(id) adRequest
                     forAdUnit:(CR_CacheAdUnit *) adUnit {
    @try {
        [self unsafeAddCriteoBidToRequest:adRequest forAdUnit:adUnit];
    }
    @catch (NSException *exception) {
        CLogException(exception);
    }
}

- (void)unsafeAddCriteoBidToRequest:(id)adRequest
                          forAdUnit:(CR_CacheAdUnit *)adUnit {
    if(!config) {
        CLog(@"Config hasn't been fetched. So no bids will be fetched.");
        return;
        // TODO : move kill switch logic out of bid manager
        // https://review.crto.in/#/c/461220/10/pubsdk/pubsdkTests/CR_BidManagerTests.m
    } else if ([config killSwitch]) {
        CLog(@"killSwitch is engaged. No bid will be fetched.");
        return;
    }

    CR_CdbBid *fetchedBid = [self getBid:adUnit];
    [self.headerBidding enrichRequest:adRequest
                              withBid:fetchedBid
                               adUnit:adUnit];
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

@end
