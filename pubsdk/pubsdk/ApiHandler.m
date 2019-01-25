//
//  ApiHandler.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 12/6/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import <WebKit/WebKit.h>
#import <AdSupport/ASIdentifierManager.h>
#import "ApiHandler.h"
#import "Config.h"

@implementation ApiHandler

- (instancetype) init {
    if(self = [super init]) {
        self.networkManager = [[NetworkManager alloc] init];
    }
    return self;
}

- (void) callCdb:(AdUnit *) adUnit
     gdprConsent:(GdprUserConsent *)gdprConsent
          config:(Config *)config
ahCdbResponseHandler: (AHCdbResponse) ahCdbResponseHandler {
    if(adUnit.adUnitId.length == 0 ||
       adUnit.size.width == 0.0f ||
       adUnit.size.height == 0.0f) {
        NSLog(@"AdUnit is missing one of the following required values adUnitId = %@, width = %f, height = %f"
              , adUnit.adUnitId, adUnit.size.width, adUnit.size.height);
        ahCdbResponseHandler(nil);
    }

    // https://confluence.criteois.com/pages/viewpage.action?pageId=436430054
    // Apple has decided to make the getUserAgent async and a pain
    // hard coding for now
    NSString *userAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 12_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16B91";
    //    NSString* userAgent;
    //    WKWebView* webKitView = [[WKWebView alloc] initWithFrame:CGRectZero];
    //    [webKitView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id __nullable userAgent, NSError * __nullable error) {
    //        if (error) {
    //            NSLog(@"%@", error.localizedDescription);
    //        } else {
    //            NSLog(@"%@", userAgent);
    //            secretAgent = userAgent;
    //        }
    //    }];

    // end hardcoded section

    // TODO: Move this to the config
    NSString *deviceModel = [[UIDevice currentDevice] name];
    NSString *deviceId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];

    NSDictionary *postBody = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSDictionary dictionaryWithObjectsAndKeys:
                               deviceId,           @"deviceId",                            //The ID that uniquely identifies a device (IDFA, GAID or Hashed Android ID)
                               @"IDFA",            @"deviceIdType",                        // The device type. This parameter can only have two values: IDFA or GAID
                               deviceModel,        @"deviceModel",
                               osVersion,          @"deviceOs",                            // The operating system of the device.
                               userAgent,          @"userAgent",
                               nil], @"user",

                              [NSDictionary dictionaryWithObjectsAndKeys:
                               [config appId],  @"bundleId",   // The bundle ID identifying the app
                               [config networkId], @"networkId",
                               nil], @"publisher",

                              [config sdkVersion], @"sdkVersion",
                              [config profileId], @"profileId",

                              [NSArray arrayWithObjects:
                               [NSDictionary dictionaryWithObjectsAndKeys:
                                adUnit.adUnitId,         @"placementId",                   // The adunit id provided in the request
                                [NSArray arrayWithObjects:[adUnit cdbSize], nil], @"sizes",
                                nil],
                               nil], @"slots",
                              [NSDictionary dictionaryWithObjectsAndKeys:
                               gdprConsent.consentString, @"consentData",
                               @(gdprConsent.gdprApplies), @"gdprApplies",
                               @(gdprConsent.consentGiven), @"consentGiven", nil], @"gdprConsent",
                              nil];

    NSString *query = [NSString stringWithFormat:@"profileId=%@", [config profileId]];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?%@", [config cdbUrl], [config path], query];
    NSURL *url = [NSURL URLWithString: urlString];

    [self.networkManager postToUrl:url postBody:postBody responseHandler:^(NSData *data, NSError *error) {
        if(error == nil) {
            if(data && ahCdbResponseHandler) {
                NSArray *cdbBids = [CdbBid getCdbResponsesFromData:data];
                ahCdbResponseHandler(cdbBids);
            } else {
                NSLog(@"Error on post to CDB : response from CDB was nil");
            }
        } else {
            NSLog(@"Error on post to CDB : %@", error);
        }
    }];
}

- (void) getConfig:(Config *) config
    ahConfigHandler:(AHConfigResponse) ahConfigHandler {
    if(![config networkId] || [config sdkVersion].length == 0 || [config appId].length == 0) {
        NSLog(@"Config is is missing one of the following required values networkId = %@, sdkVersion = %@, appId = %@ "
              , [config networkId], [config sdkVersion], [config appId]);
        if(ahConfigHandler) {
            ahConfigHandler(nil);
        }
    }

    // TODO: Move the url + query building logic to Config class
    NSString *query = [NSString stringWithFormat:@"networkId=%@&sdkVersion=%@&appId=%@", [config networkId], [config sdkVersion], [config appId]];
    NSString *urlString = [NSString stringWithFormat:@"https://pub-sdk-cfg.criteo.com/v1.0/api/config?%@", query];
    NSURL *url = [NSURL URLWithString: urlString];
    [self.networkManager getFromUrl:url responseHandler:^(NSData *data, NSError *error) {
        if(error == nil) {
            if(data && ahConfigHandler) {
                NSDictionary *configValues = [Config getConfigValuesFromData:data];
                ahConfigHandler(configValues);
            } else {
                NSLog(@"Error on get from Config: response from Config was nil");
            }
        } else {
            NSLog(@"Error on get from Config : %@", error);
        }
    }];
}

@end
