//
//  ApiHandler.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 12/6/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "ApiHandler.h"
#import "CdbBid.h"

@implementation ApiHandler

- (instancetype) init {
    if(self = [super init]) {
        self.networkManager = [[NetworkManager alloc] init];
    }
    return self;
}

- (void) callCdb:(AdUnit *) adUnit
     gdprConsent:(GdprUserConsent *)gdprConsent
ahCdbResponseHandler: (AHCdbResponse) ahCdbResponseHandler {
    if(adUnit.adUnitId.length == 0 ||
       adUnit.size.width == 0.0f ||
       adUnit.size.height == 0.0f) {
        NSLog(@"AdUnit is missing one of the following required values adUnitId = %@, width = %f, height = %f"
              , adUnit.adUnitId, adUnit.size.width, adUnit.size.height);
        ahCdbResponseHandler(nil);
    }
    
    // https://confluence.criteois.com/pages/viewpage.action?pageId=436430054
    // hardcoding for now to get things out the door
    // this should come from the config/ publisher app
    NSString *cdbUrl = @"http://directbidder-test-app.par.preprod.crto.in";
    NSString *path = @"inapp/v1";
    NSNumber *profileId = @(235);
    NSNumber *networkId = @(1);
    
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
    
    NSString *deviceModel = [[UIDevice currentDevice] name];
    NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    //hard coding for now
    NSString *bundleId = @"com.criteo.pubsdk";//[[NSBundle mainBundle] bundleIdentifier];
    NSString *sdkVersion = @"1.0";//[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
    
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
                               bundleId,  @"bundleId",   // The bundle ID identifying the app
                               networkId, @"networkId",
                               nil], @"publisher",
                              
                              sdkVersion, @"sdkVersion",
                              profileId, @"profileId",
                              
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
    
    NSString *query = [NSString stringWithFormat:@"profileId=%@", profileId];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?%@", cdbUrl, path, query];
    NSURL *url = [NSURL URLWithString: urlString];
    
    [self.networkManager postToUrl:url postBody:postBody responseHandler:^(NSData *data, NSError *error) {
        if(error == nil) {
            NSArray *cdbBids = [CdbBid getCdbResponsesFromData:data];
            ahCdbResponseHandler(cdbBids);
        } else {
            NSLog(@"%@", error);
        }
    }];
}

@end
