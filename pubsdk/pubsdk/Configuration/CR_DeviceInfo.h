//
//  CR_DeviceInfo.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
@class WKWebView;
@class CR_ThreadManager;

#if TARGET_OS_SIMULATOR
#define CR_SIMULATOR_IDFA @"8BADF00D-74BC-43D6-AA75-91D2B271A9A0"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface CR_DeviceInfo : NSObject

@property (copy, atomic) NSString *userAgent;
@property (copy, nonatomic, readonly) NSString *deviceId;

- (instancetype)initWithThreadManager:(CR_ThreadManager *)threadManager
NS_DESIGNATED_INITIALIZER;

- (void)waitForUserAgent:(void (^ _Nullable)(void))completion;
+ (CGSize)getScreenSize;
+ (BOOL)validScreenSize:(CGSize)size;
@end

NS_ASSUME_NONNULL_END
