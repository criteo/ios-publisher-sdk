//
//  MockWKWebView.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "MockWKWebView.h"

@implementation MockWKWebView

- (nullable WKNavigation *)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL {
  self.loadedBaseURL = baseURL;
  self.loadedHTMLString = string;
  [super loadHTMLString:string baseURL:baseURL];
  return nil;
}

@end
