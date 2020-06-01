//
//  CR_DefaultMediaDownloader.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CRMediaDownloader.h"

@class CR_NetworkManager;

NS_ASSUME_NONNULL_BEGIN

@interface CR_DefaultMediaDownloader : NSObject <CRMediaDownloader>

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithNetworkManager:(CR_NetworkManager *)networkManager NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
