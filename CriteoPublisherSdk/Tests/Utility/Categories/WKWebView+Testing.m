//
//  WKWebView+Testing.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "WKWebView+Testing.h"

const NSTimeInterval WKWebViewTestingEvalJavascriptTimeout = 10;

@implementation WKWebView (Testing)

- (void)testing_evaluateJavaScript:(NSString *)javaScriptString
                 validationHandler:(BOOL (^)(_Nullable id,
                                             NSError *_Nullable error))validationHandler
                 completionHandler:(void (^)(BOOL success))completionHandler {
  [self testing_evaluateJavaScript:javaScriptString
                 validationHandler:validationHandler
                           timeout:WKWebViewTestingEvalJavascriptTimeout
                 completionHandler:completionHandler];
}

- (void)testing_evaluateJavaScript:(NSString *)javaScriptString
                 validationHandler:(BOOL (^)(_Nullable id,
                                             NSError *_Nullable error))validationHandler
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
                 validationHandler:(BOOL (^)(_Nullable id,
                                             NSError *_Nullable error))validationHandler
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
               dispatch_time_t time =
                   dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC));
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
