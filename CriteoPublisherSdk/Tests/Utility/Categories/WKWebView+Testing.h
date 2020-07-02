//
//  WKWebView+Testing.h
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

#import <XCTest/XCTest.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

extern const NSTimeInterval WKWebViewTestingEvalJavascriptTimeout;

@interface WKWebView (Testing)

- (void)testing_evaluateJavaScript:(NSString *)javaScriptString
                 validationHandler:(BOOL (^)(_Nullable id,
                                             NSError *_Nullable error))validationHandler
                 completionHandler:(void (^)(BOOL success))completionHandler;

- (void)testing_evaluateJavaScript:(NSString *)javaScriptString
                 validationHandler:(BOOL (^)(_Nullable id,
                                             NSError *_Nullable error))validationHandler
                           timeout:(NSUInteger)timeout
                 completionHandler:(void (^)(BOOL success))completionHandler;
@end

NS_ASSUME_NONNULL_END
