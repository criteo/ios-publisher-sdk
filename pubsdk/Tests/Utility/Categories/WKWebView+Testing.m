//
//  WKWebView+Testing.m
//  pubsdk
//
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "WKWebView+Testing.h"

const NSTimeInterval WKWebViewTestingEvalJavascriptTimeout = 10;

@implementation WKWebView (Testing)

- (void)testing_evaluateJavaScript:(NSString *)javaScriptString
                 validationHandler:(BOOL (^)(_Nullable id, NSError * _Nullable error))validationHandler
                 completionHandler:(void (^)(BOOL success))completionHandler {
    [self testing_evaluateJavaScript:javaScriptString
                   validationHandler:validationHandler
                             timeout:WKWebViewTestingEvalJavascriptTimeout
                   completionHandler:completionHandler];
}

- (void)testing_evaluateJavaScript:(NSString *)javaScriptString
                 validationHandler:(BOOL (^)(_Nullable id, NSError * _Nullable error))validationHandler
                           timeout:(NSUInteger)timeout
                 completionHandler:(void (^)(BOOL success))completionHandler {
    NSDate *timeoutDate = [[NSDate alloc] initWithTimeIntervalSinceNow:timeout];
    [self testing_evaluateJavaScript:javaScriptString
                   validationHandler:validationHandler
                         timeoutDate:timeoutDate
                   completionHandler:completionHandler];
}

#pragma mark - Private

- (void)testing_evaluateJavaScript:(NSString *)javaScriptString
                 validationHandler:(BOOL (^)(_Nullable id, NSError * _Nullable error))validationHandler
                       timeoutDate:(NSDate *)timeoutDate
                 completionHandler:(void (^)(BOOL success))completionHandler {
    __weak typeof(self) weakSelf = self;
    [self evaluateJavaScript:javaScriptString
           completionHandler:^(NSString *htmlContent, NSError *err) {
               typeof(self) strongSelf = weakSelf;
               if (strongSelf == nil) {
                   return;
               }

               if (validationHandler(htmlContent, err)) {
                   completionHandler(YES);
               } else {
                   NSDate *now = [[NSDate alloc] init];
                   if ([now compare:timeoutDate] == NSOrderedAscending) {
                       dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC));
                       dispatch_after(time, dispatch_get_main_queue(), ^{
                           [strongSelf testing_evaluateJavaScript:javaScriptString
                                                validationHandler:validationHandler
                                                      timeoutDate:timeoutDate
                                                completionHandler:completionHandler];
                       });
                   } else {
                       completionHandler(NO);
                   }
              }
              }];
}

@end
