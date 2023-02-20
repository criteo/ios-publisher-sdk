//
//  CRMRAIDHandler.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2023 Criteo. All rights reserved.
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

#import "CRMRAIDHandler.h"

@interface CRMRAIDHandler ()
@property(nonatomic, strong) WKWebView *webView;
- (void)sendReadyEventWithPlacement:(NSString *)placementType;
@end


@implementation CRMRAIDHandler
- (instancetype)initWithWebView:(WKWebView *)webview {
    if (self = [super init]) {
        _webView = webview;
    }

    return self;
}

#pragma mark - mraid js interaction
- (void)onAdLoadFinishWithPlacement:(NSString *)placementType {
    [self sendReadyEventWithPlacement:placementType];
}

- (void)sendError:(NSString *)error action:(NSString *)action {
    NSString *errorCommand = [NSString stringWithFormat:@"window.mraid.notifyError(\"%@\",\"%@\");", error, action];
    [_webView evaluateJavaScript:errorCommand completionHandler:NULL];
}

#pragma mark - internal utilities
- (void)sendReadyEventWithPlacement:(NSString *)placementType {
    NSString *jsCommand = [NSString stringWithFormat:@"window.mraid.notifyReady(\"%@\");", placementType];
    [_webView evaluateJavaScript: jsCommand completionHandler:NULL];
}

@end
