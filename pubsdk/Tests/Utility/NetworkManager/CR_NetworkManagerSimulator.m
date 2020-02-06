//
//  CR_NetworkSessionPlayer.m
//  pubsdk
//
//  Created by Romain Lofaso on 12/17/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_ApiHandler.h"
#import "CR_Config.h"
#import "CR_NetworkManagerSimulator.h"
#import "CR_NetworkCaptor.h"
#import "CR_NetworkSessionReader.h"
#import "CR_DeviceInfo.h"
#import "Criteo+Testing.h"
#import "MockWKWebView.h"
#import "NSURL+Testing.h"

NSString *const CR_NetworkManagerMockSlotForPreprodBannerAdUnit =  @"{\"impId\":\"5e399d7e1d22e0c14d90f1702478d260\",\"placementId\":\"test-PubSdk-Base\",\"arbitrageId\":\"arbitrage_id\",\"cpm\":\"1.00\",\"currency\":\"EUR\",\"width\":320,\"height\":50,\"ttl\":0,\"displayUrl\":\"https://directbidder-uat-stubs.par.preprod.crto.in/delivery/ajs.php?width=320&height=50\"}";

NSString *const CR_NetworkManagerMockSlotForPreprodInterstitialAdUnit = @"{\"impId\":\"5e399ddd211004a9883cca970ef2adf4\",\"placementId\":\"test-PubSdk-Interstitial\",\"arbitrageId\":\"arbitrage_id\",\"cpm\":\"1.00\",\"currency\":\"EUR\",\"width\":375,\"height\":812,\"ttl\":0,\"displayUrl\":\"https://directbidder-uat-stubs.par.preprod.crto.in/delivery/ajs.php?width=375&height=812\"}";


NSString *const CR_NetworkManagerMockSlotForPreprodNativeAdAdUnit = @"{\"impId\":\"5e399dbe2aecdfaf651de1ffa48d4c6f\",\"placementId\":\"test-PubSdk-Native\",\"arbitrageId\":\"\",\"cpm\":\"1.00\",\"currency\":\"EUR\",\"width\":2,\"height\":2,\"ttl\":0,\"native\":{\"products\":[{\"title\":\"Criteo native solution\",\"description\":\"A smart solution for your Native advertising\",\"price\":\"10$\",\"clickUrl\":\"https://www.criteo.com/products/\",\"callToAction\":\"Try it now!\",\"image\":{\"url\":\"https://publisherdirect.criteo.com/publishertag/preprodtest/creative.png\",\"height\":300,\"width\":300}}],\"advertiser\":{\"description\":\"Our digital marketing solutions are trusted\",\"domain\":\"criteo.com\",\"logo\":{\"url\":\"https://www.criteo.com/images/criteo-logo.svg\",\"height\":300,\"width\":300},\"logoClickUrl\":\"https://www.criteo.com\"},\"privacy\":{\"optoutClickUrl\":\"https://info.criteo.com/privacy/informations\",\"optoutImageUrl\":\"https://static.criteo.net/flash/icon/nai_small.png\",\"longLegalText\":\"\"},\"impressionPixels\":[{\"url\":\"https://my-impression-pixel/test/impression\"},{\"url\":\"https://cas.com/lg.com\"}]}}";

NSString *const CR_NetworkManagerMockSlotForDemoBannerAdUnitId = @"{\"impId\":\"5e399d9984fd51e2add966fdfced4804\",\"placementId\":\"30s6zt3ayypfyemwjvmp\",\"arbitrageId\":\"3a925b55-e9fc-4b04-bf40-19dccd73a89e\",\"cpm\":\"20.00\",\"currency\":\"USD\",\"width\":320,\"height\":50,\"ttl\":3600,\"displayUrl\":\"https://rdi.eu.preprod.criteo.com/delivery/rtb/demo/ajs?zoneid=1417086&width=320&height=50&ibva=0&uaCap=3\"}";

NSString *const CR_NetworkManagerMockSlotForDemoInterstitialUnitId = @"{\"impId\":\"5e399ddbe6e63e33243ba388241e3101\",\"placementId\":\"6yws53jyfjgoq1ghnuqb\",\"arbitrageId\":\"cba4c897-f6a6-434b-9968-437be9669e1a\",\"cpm\":\"20.00\",\"currency\":\"USD\",\"width\":375,\"height\":812,\"ttl\":3600,\"displayUrl\":\"https://rdi.eu.preprod.criteo.com/delivery/rtb/demo/ajs?zoneid=1417086&width=375&height=812&intl=1&ibva=0&uaCap=3\"}";


NSString *const CR_NetworkSessionReplayerKillSwitchFalse = @"{\"killSwitch\":false,\"AndroidDisplayUrlMacro\":\"%%displayUrl%%\",\"AndroidAdTagUrlMode\":\"<html><body style='text-align:center; margin:0px; padding:0px; horizontal-align:center;'><script src=\\\"%%displayUrl%%\\\"></script></body></html>\",\"AndroidAdTagDataMacro\":\"%%adTagData%%\",\"AndroidAdTagDataMode\":\"<html><body style='text-align:center; margin:0px; padding:0px; horizontal-align:center;'><script>%%adTagData%%</script></body></html>\",\"iOSDisplayUrlMacro\":\"%%displayUrl%%\",\"iOSWidthMacro\":\"%%width%%\",\"iOSAdTagUrlMode\":\"<!doctype html><html><head><meta charset=\\\"utf-8\\\"><style>body{margin:0;padding:0}</style><meta name=\\\"viewport\\\" content=\\\"width=%%width%%, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\\\" ></head><body><script src=\\\"%%displayUrl%%\\\"></script></body></html>\"}";

NSString *const CR_NetworkSessionReplayerGumReponse = @"{\"throttleSec\":5}";

NSString *const CR_NetworkSessionEmptyBid = @"{\"slots\":[],\"requestId\":\"c412223b-7c6b-4754-931c-708925e5ce4d\"}";

@interface CR_NetworkManagerSimulator ()

@property (nonatomic, strong, readonly) CR_Config *config;
@property (nonatomic, strong, readonly) NSDictionary *bidSlotResponses;

@end

@implementation CR_NetworkManagerSimulator

- (instancetype)initWithConfig:(CR_Config *)config {
    MockWKWebView *webView = [[MockWKWebView alloc] init];
    CR_DeviceInfo *deviceInfo = [[CR_DeviceInfo alloc] initWithWKWebView:webView];
    if (self = [super initWithDeviceInfo:deviceInfo]) {
        _config = config;
        _bidSlotResponses = @{
            PreprodBannerAdUnitId : CR_NetworkManagerMockSlotForPreprodBannerAdUnit,
            PreprodInterstitialAdUnitId : CR_NetworkManagerMockSlotForPreprodInterstitialAdUnit,
            PreprodNativeAdUnitId : CR_NetworkManagerMockSlotForPreprodNativeAdAdUnit,
            DemoBannerAdUnitId: CR_NetworkManagerMockSlotForDemoBannerAdUnitId,
            DemoInterstitialAdUnitId: CR_NetworkManagerMockSlotForDemoInterstitialUnitId
        };
    }
    return self;
}

- (void)getFromUrl:(NSURL *)url
   responseHandler:(CR_NMResponse)responseHandler {
    if (!responseHandler) return;

    if ([url testing_isConfigEventUrlWithConfig:self.config]) {
        NSData *response = [CR_NetworkSessionReplayerKillSwitchFalse dataUsingEncoding:NSUTF8StringEncoding];
        responseHandler(response, nil);
        return;
    } else if ([url testing_isAppEventUrlWithConfig:self.config]) {
        NSData *response = [CR_NetworkSessionReplayerGumReponse dataUsingEncoding:NSUTF8StringEncoding];
        responseHandler(response, nil);
        return;
    }

    NSAssert(NO, @"Unknown URL in GET: %@", url);
}

- (void) postToUrl:(NSURL *)url
          postBody:(NSDictionary *)postBody
   responseHandler:(CR_NMResponse)responseHandler {
    if (!responseHandler) return;

    if ([url testing_isBidUrlWithConfig:self.config]) {
        NSError *error = NULL;
        NSData *response = [self _handleBidRequestWithUrl:url
                                                 postBody:postBody
                                                    error:&error];
        responseHandler(response, error);
        return;
    }

    NSAssert(NO, @"Unknown URL in POST: %@\nBody: %@", url, postBody);
}

#pragma mark - Private

- (NSData *)_handleBidRequestWithUrl:(NSURL *)url
                            postBody:(NSDictionary *)postBody
                               error:(NSError **)error {
    NSArray *slots = postBody[CR_ApiHandlerBidSlotsKey];
    NSMutableArray *slotResponses = [[NSMutableArray alloc] init];
    for (NSDictionary *slot in slots) {
        NSString *placementId = slot[CR_ApiHandlerBidSlotsPlacementIdKey];
        NSString *slotResponse = self.bidSlotResponses[placementId];
        if (slotResponse) {
            [slotResponses addObject:slotResponse];
        }
    }

    if (slotResponses.count == 0) {
        return [CR_NetworkSessionEmptyBid dataUsingEncoding:NSUTF8StringEncoding];
    }

    NSString *joinedSlots = [slotResponses componentsJoinedByString:@","];
    NSString *response = [[NSString alloc] initWithFormat:@"{\"slots\":[%@],\"requestId\":\"c412223b-7c6b-4754-931c-708925e5ce4d\"}", joinedSlots];
    return [response dataUsingEncoding:NSUTF8StringEncoding];
}

@end
