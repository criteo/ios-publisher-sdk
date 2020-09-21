//
//  CR_SynchronousThreadManager.h
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

#import "CR_ThreadManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface CR_SynchronousThreadManager : CR_ThreadManager

@property(nonatomic, assign) BOOL isTimeout;

@end

NS_ASSUME_NONNULL_END
