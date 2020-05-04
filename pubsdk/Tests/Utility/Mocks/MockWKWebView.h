//
//  MockWKWebView.h
//  pubsdkTests
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MockWKWebView : WKWebView
@property NSString *loadedHTMLString;
@property NSURL *loadedBaseURL;
@end

NS_ASSUME_NONNULL_END
