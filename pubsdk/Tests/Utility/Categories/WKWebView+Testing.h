//
//  WKWebView+Testing.h
//  pubsdk
//
//  Created by Romain Lofaso on 4/6/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

extern const NSTimeInterval WKWebViewTestingEvalJavascriptTimeout;

@interface WKWebView (Testing)

- (void)testing_evaluateJavaScript:(NSString *)javaScriptString
                 validationHandler:(BOOL (^)(_Nullable id, NSError * _Nullable error))validationHandler
                 completionHandler:(void (^)(BOOL success))completionHandler;

- (void)testing_evaluateJavaScript:(NSString *)javaScriptString
                 validationHandler:(BOOL (^)(_Nullable id, NSError * _Nullable error))validationHandler
                           timeout:(NSUInteger)timeout
                 completionHandler:(void (^)(BOOL success))completionHandler;
@end

NS_ASSUME_NONNULL_END
