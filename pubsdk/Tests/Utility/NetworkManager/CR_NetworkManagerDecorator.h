//
//  CR_NetworkManagerDecorator.h
//  pubsdk
//
//  Created by Romain Lofaso on 12/18/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CR_NetworkManager;

NS_ASSUME_NONNULL_BEGIN

@interface CR_NetworkManagerDecorator : NSObject

@property (nonatomic, assign, getter=isRecording) BOOL recording;
@property (nonatomic, assign, getter=isReplaying) BOOL replaying;
@property (nonatomic, assign, getter=isCapturing) BOOL capturing;

+ (instancetype)decoratorFromConfiguration;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithRecordind:(BOOL)recording
                        replaying:(BOOL)replaying
                        capturing:(BOOL)capturing NS_DESIGNATED_INITIALIZER;

/** Should be called in the same thread of the test method. */
- (CR_NetworkManager *)decorateNetworkManager:(CR_NetworkManager *)networkManager;

@end

NS_ASSUME_NONNULL_END
