//
//  AdViewerCdbApi.m
//  AdViewer - Call CDB API (PubSDK protype)
//
//  Created by Yegor Pavlikov on 11/9/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import "AdViewerCdbApi.h"


// Constans - better defined in a separate file, keeping it here for simplicity
#define kCDB_URL       @"https://bidder.criteo.com"


@interface AdViewerCdbApi() {}
@end


@implementation AdViewerCdbApi

// We will use no libraries to call API to mimimize app footprint
// Univercal REST calling (GET, POST, PUT, DELETE)

// Example call from the doc: https://confluence.criteois.com/pages/viewpage.action?pageId=436430054
//POST /cdb?profileId=217&debug=1 HTTP/1.1
//Content-Type: application/json
//User-Agent: Dalvik/2.1.0 (Linux; U; Android 8.1.0; Nexus 6P Build/OPM6.171019.030.H1)
//Host: bidder.criteo.com
//Connection: Keep-Alive
//Accept-Encoding: gzip
//Content-Length: 410

- (NSString *)requestApiCall: (NSString*)requestHTTPMethod
                 requestPath: (NSString *)requestPath
                requestQuery: (NSString *)requestQuery
                 requestBody: (NSDictionary *)requestBody
{
    NSString *kBaseURL = kCDB_URL;
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@/%@?%@", kBaseURL, requestPath, requestQuery];
    NSURL *url = [NSURL URLWithString: urlAsString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval: 30.0f];                                         // Adjust the timeout
    
    [urlRequest setHTTPMethod:requestHTTPMethod];
    if (![requestHTTPMethod isEqualToString:@"GET"]) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:requestBody options:NSJSONWritingPrettyPrinted error:&error];
        NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"jsonData as string:\n%@", resultAsString);
        
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[resultAsString length]] forHTTPHeaderField:@"Content-Length"];
        [urlRequest setHTTPBody: jsonData];
    }
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection
     sendAsynchronousRequest: urlRequest
     queue: queue
     completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error) {
         NSInteger status = [(NSHTTPURLResponse *)response statusCode];
         
         BOOL expired = NO;
         NSDictionary *jsonResponse;
         
         if (error != nil) {
             if (error.code == -1012) {
                 expired = YES;
                 self->errorMessage = nil;
                 //[self refreshSessionUsingToken];
             } else {
                 NSLog(@"Error = %@", error);
                 self->errorMessage = [error localizedDescription];
             }
         } else {
             
             NSError *e = nil;
             if ([data length] > 0) {
                 jsonResponse = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &e];
             }
             
             if (e == nil)
             {
#ifdef DEBUG
                 NSLog(@"requestApiCall: Response - %@", jsonResponse);
#endif
                 if (status != 200)
                 {
                     self->errorMessage = [jsonResponse objectForKey:@"Message"];
                     int code = [[jsonResponse objectForKey:@"Code"] intValue];
                     
                     if (code == 401) {
                         NSLog(@"401, session has expired, %@", self->errorMessage);
                         expired = YES;
                         self->errorMessage = nil;
                         //[self refreshSessionUsingToken];
                     }
                     else {
                         NSLog(@"requestApiCall: API Error %i, %@", code, self->errorMessage);
                     }
                 }
             }
             else {
                 NSLog(@"requestApiCall: Error = %@", e);
                 self->errorMessage = [e localizedDescription];
             }
         }
         if (self.delegate && !expired) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.delegate AdViewerAPI: self didFinishLoading:
                  jsonResponse message: self->errorMessage
                              selector: self->selector];
             });
         }
     }
     
     ];
    return errorMessage;
}
    
- (id)initWithSelector:(enum methodSelector)selector delegate:(id)delegate {
    self.delegate = delegate;
    selector = selector;
    return self;
}

    
- (void)AdViewerAPI:(AdViewerCdbApi *)api didFinishLoading:(NSDictionary *)response message:(NSString *)message
    selector:(enum methodSelector)selector {
   
    if (self.delegate) {
        [self.delegate AdViewerAPI: self
                  didFinishLoading: nil
                           message: nil
                          selector: selector];
    }
}


- (NSString*) deviceName {
    struct utsname systemInfo;
    uname(&systemInfo);

    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

#pragma mark Load Ad to display

- (NSString *)LoadAd: (NSDictionary *)requestData
{
    NSString *path = @"cdb";

    // Get request parameters
    NSString *query = [NSString stringWithFormat:@"profileId=%@&debug=1", requestData[@"profileId"]];
    NSString *impId = requestData[@"impId"];

    // example from https://confluence.criteois.com/pages/viewpage.action?pageId=436430054
    //{
    //    "publisher": {
    //        "bundleid": "com.criteo.criteopublishersdksample",  //The bundle ID identifying the app
    //        "appname": "CriteoPublisherSDKSample",
    //        "url": "https:\/\/play.google.com\/store\/apps\/details?id=com.olx.southasia"
    //    },
    //    "user": {
    //        "deviceid": "b47032ee-497a-4324-9c52-4c19062d76c2", //The ID that uniquely identifies a device (IDFA, GAID or Hashed Android ID)
    //        "deviceidtype": "GAID",                             //The device type. This parameter can only have two values: IDFA or GAID
    //        "devicemodel": "Nexus 6P",
    //        "deviceos": "Android",                              //The operating system of the device.
    //        "sdkver": "1.3.0",                                  //SDK version
    //        "lmt": "0",                                         //Limited Ad Tracking parameter signaling the tracking preferences of the user.
    //        "connection": "WIFI",
    //        "User-Agent": "Mozilla/5.0 (Linux; U; Android .."   //The webview user-agent of the device
    //    },
    //    "slots":
    //              {
    //                  "impid": "1139617",    //The adunit id provided in the request
    //                  "zoneid": "1139617",   //The Criteo zoneid provided in the request
    //                  "native": true         //Native assets
    //              }
    //              ],
    //    "gdprConsent": {
    //        "consentData": ".....",     // CDB is responsible for taking care
    //        "gdprApplies": false,       // of GDPR. The response can be Ad or no Ad.
    //        "consentGiven": true
    //    }
    //}

    NSString* deviceModel = [self deviceName];
    NSString* deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString* secretAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];

    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    NSString *sdkVersion = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];

    NSDictionary *reqData = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSDictionary dictionaryWithObjectsAndKeys:
            bundleId,                                   @"bundleid",   // The bundle ID identifying the app
            @"CriteoPublisherSDKSample",                @"appname",
            @"https://play.google.com/store/apps/details?id=com.olx.southasia", @"url",  // Replace with appstore URL
            nil], @"publisher",

        [NSDictionary dictionaryWithObjectsAndKeys:
            deviceId,           @"deviceid",                            //The ID that uniquely identifies a device (IDFA, GAID or Hashed Android ID)
            @"IDFA",            @"deviceidtype",                        // The device type. This parameter can only have two values: IDFA or GAID
            deviceModel,        @"devicemodel",
            osVersion,          @"deviceos",                            // The operating system of the device.
            sdkVersion,         @"sdkver",                              // SDK version
            @"0",               @"lmt",                                 // Limited Ad Tracking parameter signaling the tracking preferences of the user.
            @"WIFI",            @"connection",
            secretAgent,        @"User-Agent",
            nil], @"user",

        [NSArray arrayWithObjects:
            [NSDictionary dictionaryWithObjectsAndKeys:
                 impId,         @"impid",                               // The adunit id provided in the request
                 @"1139617",    @"zoneid",                              // The Criteo zoneid provided in the request
                 [NSNumber numberWithBool: YES], @"native",             // Native assets
                 nil],
            nil], @"slots",

        [NSDictionary dictionaryWithObjectsAndKeys:
           @".....", @"consentData",                                    // CDB is responsible for taking care
           [NSNumber numberWithBool: NO], @"gdprApplies",               // of GDPR. The response can be Ad or no Ad.
           [NSNumber numberWithBool: YES], @"consentGiven",
           nil], @"gdprConsent",

        nil];

    return [self requestApiCall: @"POST"
                    requestPath: path
                   requestQuery: query
                    requestBody: reqData];
}


@end
