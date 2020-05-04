//
//  CR_DeviceInfo.h
//  pubsdk
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
@class WKWebView;
@class CR_ThreadManager;

NS_ASSUME_NONNULL_BEGIN

@interface CR_DeviceInfo : NSObject

@property (copy, atomic) NSString *userAgent;
@property (copy, nonatomic, readonly) NSString *deviceId;

- (instancetype)initWithThreadManager:(CR_ThreadManager *)threadManager;
- (instancetype)initWithThreadManager:(CR_ThreadManager *)threadManager
                              webView:(WKWebView *)webView
NS_DESIGNATED_INITIALIZER;

- (void)waitForUserAgent:(void (^ _Nullable)(void))completion;
+ (CGSize)getScreenSize;
+ (BOOL)validScreenSize:(CGSize)size;
@end

NS_ASSUME_NONNULL_END
