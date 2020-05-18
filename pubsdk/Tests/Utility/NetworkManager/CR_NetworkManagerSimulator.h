//
//  CR_NetworkSessionPlayer.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_NetworkManager.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const CR_NetworkManagerSimulatorDefaultCpm;
extern NSString * const CR_NetworkManagerSimulatorDefaultDisplayUrl;
extern const NSTimeInterval CR_NetworkManagerSimulatorInterstitialDefaultTtl;

@class CR_Config;

@interface CR_NetworkManagerSimulator : CR_NetworkManager

@property (class, assign, nonatomic, readonly) NSTimeInterval interstitialTtl;

- (instancetype)initWithDeviceInfo:(CR_DeviceInfo *)deviceInfo NS_UNAVAILABLE;
- (instancetype)initWithDeviceInfo:(CR_DeviceInfo *)deviceInfo session:(NSURLSession *)session NS_UNAVAILABLE;
- (instancetype)initWithConfig:(CR_Config *)config NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
