//
//  CR_NetworkRecorder.h
//  pubsdk
//
//  Created by Romain Lofaso on 12/17/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_NetworkManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface CR_NetworkSessionRecorder : CR_NetworkManager

@property (nonatomic, strong, readonly) CR_NetworkManager *networkManager;
@property (nonatomic, copy, readonly) NSString  *sessionIdentifier;

- (instancetype)initWithNetworkManager:(CR_NetworkManager *)networkManager
                     sessionIdentifier:(NSString *)sessionIdentifier;

- (void)flush;

@end

NS_ASSUME_NONNULL_END
