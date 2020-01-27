//
//  MockWKWebView.m
//  pubsdkTests
//
//  Created by Julien Stoeffler on 4/5/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "MockWKWebView.h"

@implementation MockWKWebView

- (nullable WKNavigation *)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL
{
    self.loadedBaseURL = baseURL;
    self.loadedHTMLString = string;
    [super loadHTMLString:string baseURL:baseURL];
    return nil;
}

@end
