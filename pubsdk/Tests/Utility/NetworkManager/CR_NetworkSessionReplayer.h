//
//  CR_NetworkSessionPlayer.h
//  pubsdk
//
//  Created by Romain Lofaso on 12/17/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_NetworkManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface CR_NetworkSessionReplayer : CR_NetworkManager

- (instancetype)initWithDeviceInfo:(CR_DeviceInfo *)deviceInfo NS_UNAVAILABLE;
- (instancetype)initWithNetworkManager:(nullable CR_NetworkManager *)networkManager
                     sessionIdentifier:(NSString *)identifier NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
