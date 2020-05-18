//
//  CR_DeviceInfoMock.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_DeviceInfoMock.h"
#import "CR_ThreadManager.h"
#import "MockWKWebView.h"

NSString * const CR_DeviceInfoMockDefaultCrtSize = @"320x480";
NSString * const CR_DeviceInfoMockDefaultUserAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148";

@implementation CR_DeviceInfoMock

- (instancetype)init {
    MockWKWebView *webView = [[MockWKWebView alloc] init];
    CR_ThreadManager *threadManager = [[CR_ThreadManager alloc] init];
    self = [super initWithThreadManager:threadManager
                                webView:webView];
    if (self) {
        _mock_isPhone = YES;
        _mock_isInPortrait = YES;
        _mock_screenSize = (CGSize) { 320.f, 480.f };
        self.userAgent = CR_DeviceInfoMockDefaultUserAgent;
    }
    return self;
}

- (BOOL)isPhone {
    return self.mock_isPhone;
}

- (BOOL)isInPortrait {
    return self.mock_isInPortrait;
}

- (CGSize)screenSize {
    return self.mock_screenSize;
}

- (void)waitForUserAgent:(void (^ _Nullable)(void))completion {
    if (completion != nil) {
        completion();
    }
}

@end
