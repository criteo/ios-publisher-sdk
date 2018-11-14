//
//  AdViewerCdbApi.m
//  AdViewer - Call CDB API (PubSDK protype)
//
//  Created by Yegor Pavlikov on 11/9/18.
//  Copyright © 2018 Criteo. All rights reserved.
//


#import "AdViewerCdbApi.h"


// Constans - better defined in a separate file, keeping it here for simplicity
#define kCDB_URL      @"http://directbidder-test-app.par.preprod.crto.in"
//#define kCDB_URL      @"http://bidder.criteo.com"

#ifndef DEBUG
#define DebugLog(...)
#else
#define DebugLog(...) NSLog(__VA_ARGS__)
#endif



@interface AdViewerCdbApi() {}
@end

@implementation AdViewerCdbApi

// We will use no libraries to call API to mimimize app footprint
// Univercal REST calling (GET, POST, PUT, DELETE)
// Example call: https://confluence.criteois.com/pages/viewpage.action?pageId=436430054


- (NSString *)requestApiCall: (NSString *)requestHTTPMethod
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
        DebugLog(@"requestApiCall: Request as string:\n%@", resultAsString);
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[resultAsString length]] forHTTPHeaderField:@"Content-Length"];
        [urlRequest setHTTPBody: jsonData];
    }


    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *uploadTask = [session dataTaskWithRequest:urlRequest
                                                  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

         NSDictionary *responseBody;

         NSHTTPURLResponse *httpurlresponse = (NSHTTPURLResponse *)response;
         long responseStatus = [httpurlresponse statusCode];
         NSDictionary *responseHeader = [httpurlresponse allHeaderFields];

         DebugLog(@"requestApiCall: Response header %@", responseHeader);

         if (error != nil) {

             NSLog(@"requestApiCall: sendAsynchronousRequest error: %@", error);
             self->errorMessage = [error localizedDescription];

         } else {

             NSError *err = nil;

             if ([data length] > 0) {
                 responseBody = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &err];
             }

             if (err == nil)
             {
                 DebugLog(@"requestApiCall: Response payload %@", responseBody);
                 if (responseStatus != 200)
                 {
                     NSLog(@"requestApiCall: API Error: %ld, %@", responseStatus, self->errorMessage);
                 }
             }
             else {
                 NSLog(@"requestApiCall: JOSN Serialization Error: %@", err);
                 self->errorMessage = [err localizedDescription];
             }
         }

         if (self.delegate) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.delegate AdViewerAPI: self
                           didFinishLoading: responseBody
                                     header: responseHeader
                                    message: self->errorMessage
                                   selector: self->selector];
             });
         }
    }];
    [uploadTask resume];

    return errorMessage;

}


- (id)initWithSelector:(enum methodSelector)selector delegate:(id)delegate {
    self.delegate = delegate;
    selector = selector;
    return self;
}


- (void)AdViewerAPI:(AdViewerCdbApi *)api
   didFinishLoading:(NSDictionary *)response
             header:(NSDictionary*)header
            message:(NSString *)message
           selector:(enum methodSelector)selector {

    if (self.delegate) {
        [self.delegate AdViewerAPI: self
                  didFinishLoading: nil
                            header: nil
                           message: nil
                          selector: selector];
    }
}


- (NSString*)deviceName {
    struct utsname systemInfo;
    uname(&systemInfo);

    return [NSString stringWithCString: systemInfo.machine
                              encoding: NSUTF8StringEncoding];
}


- (NSString*)stringFromJSONObject: (NSDictionary*)jsonObject {
    NSError *error;
    NSString *jsonString;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: jsonObject
                                                       options: NSJSONWritingPrettyPrinted
                                                         error: &error];

    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }

    return jsonString;
}


#pragma mark Load Ad to store in memory

- (NSString *)loadAdWithCDB: (NSDictionary *)requestData
{
    NSString *path = @"cdb";

    // Get request parameters
    NSString *query = [NSString stringWithFormat:@"profileId=%@&debug=1", requestData[@"profileId"]];
    NSString *impId = requestData[@"impId"];

    // example is at https://confluence.criteois.com/pages/viewpage.action?pageId=436430054

    NSString* deviceModel = [self deviceName];
    NSString* deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString* secretAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];

//    static NSString* secretAgent;
//    WKWebView* webKitView = [[WKWebView alloc] initWithFrame:CGRectZero];
//    [webKitView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id __nullable userAgent, NSError * __nullable error) {
//        if (error) {
//            NSLog(@"%@", error.localizedDescription);
//        } else {
//            NSLog(@"%@", userAgent);
//            secretAgent = userAgent;
//        }
//    }];


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
