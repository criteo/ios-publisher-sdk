//
//  CR_DeviceInfoMock.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_DeviceInfo+Testing.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const CR_DeviceInfoMockDefaultCrtSize;

@interface CR_DeviceInfoMock : CR_DeviceInfo

@property (assign, nonatomic) BOOL mock_isPhone; // Default YES.
@property (assign, nonatomic) BOOL mock_isInPortrait; // Default YES.
@property (assign, nonatomic) CGSize mock_screenSize; // Default 320/480.

@end

NS_ASSUME_NONNULL_END
