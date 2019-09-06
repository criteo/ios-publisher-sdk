//
//  CR_DeviceInfo.h
//  pubsdk
//
//  Created by Paul Davis on 1/28/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
@class WKWebView, UIWebView;
NS_ASSUME_NONNULL_BEGIN

@interface CR_DeviceInfo : NSObject

@property (copy, atomic) NSString *userAgent;
@property (copy, nonatomic, readonly) NSString *deviceId;

- (instancetype)initWithWKWebView:(WKWebView *)wkWebView uiWebView:(UIWebView * _Nullable)uiWebView;
- (void)waitForUserAgent:(void (^ _Nullable)(void))completion;
+ (CGSize)getScreenSize;
@end

NS_ASSUME_NONNULL_END
