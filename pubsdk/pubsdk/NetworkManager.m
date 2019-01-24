//
//  NetworkManager.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 12/6/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import "NetworkManager.h"

@implementation NetworkManager;

- (instancetype) init {
    self = [super init];
    self.config = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:self.config];
    return self;
}

- (void) getFromUrl:(NSURL *) url
        queryParams:(NSDictionary *) queryParams
    responseHandler:(NMResponse) responseHandler {
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:url
                                             completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error) {
            // Add logging or metrics code here
            responseHandler(nil, error);
        }
        if (response) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
            if (httpResponse.statusCode >=200 && httpResponse.statusCode <=299) {
                responseHandler(data, error);
            }
            else {
                // Add logging or metrics code here
                // Need to figure out how to handle redirects
            }
        }
    }];
    [task resume];
}

- (void) postToUrl:(NSURL *) url
          postBody:(NSDictionary *) postBody
   responseHandler:(NMResponse) responseHandler {
    
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:url];
    [postRequest setTimeoutInterval: 30];
    [postRequest setHTTPMethod:@"POST"];
    
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postBody options:NSJSONWritingPrettyPrinted error:&jsonError];

    //debug code
    //NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //NSLog(@"NetworkManager url: %@ \nbody:\n %@",url, jsonString);

    //[postRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [postRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //[postRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [postRequest setHTTPBody: jsonData];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:postRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error) {
            // Add logging or metrics code here
            responseHandler(nil, error);
        }
        if (response) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
            // 204 is no content and needs to be handled on it's own
            if (httpResponse.statusCode == 204) {
                responseHandler(nil, error);
            }
            if (httpResponse.statusCode >=200 && httpResponse.statusCode <=299) {
                responseHandler(data, error);
            }
            else {
                // Add logging or metrics code here
            }
        }
    }];
    [task resume];
}

@end
