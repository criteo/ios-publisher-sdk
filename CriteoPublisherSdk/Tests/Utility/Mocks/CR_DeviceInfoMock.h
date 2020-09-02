//
//  CR_DeviceInfoMock.h
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "CR_DeviceInfo+Testing.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString* const CR_DeviceInfoMockDefaultCrtSize;

@interface CR_DeviceInfoMock : CR_DeviceInfo

- (instancetype)init;

@property(assign, nonatomic) BOOL mock_isPhone;       // Default YES.
@property(assign, nonatomic) BOOL mock_isInPortrait;  // Default YES.
@property(assign, nonatomic) CGSize mock_screenSize;  // Default 320/480.

@end

NS_ASSUME_NONNULL_END
