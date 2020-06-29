//
//  MockWKWebView.h
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MockWKWebView : WKWebView
@property NSString *loadedHTMLString;
@property NSURL *loadedBaseURL;
@end

NS_ASSUME_NONNULL_END
