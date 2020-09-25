//
//  CR_FeedbackStorage.h
//  CriteoPublisherSdk
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

#ifndef CR_FeedbackStorage_Internal_h
#define CR_FeedbackStorage_Internal_h

#import "CR_FeedbackStorage.h"

@interface CR_FeedbackStorage ()

- (instancetype)initWithSendingQueueMaxSize:(NSUInteger)sendingQueueMaxSize
                                fileManager:(id<CR_FeedbackFileManaging>)fileManager;

- (CR_CASObjectQueue<CR_FeedbackMessage *> *)
    buildSendingQueueWithMaxSize:(NSUInteger)sendingQueueMaxSize
                     fileManager:(CR_FeedbackFileManager *)fileManage;

- (NSString *)getOrCreateFilenameForAdUnit:(CR_CacheAdUnit *)adUnit;

- (CR_FeedbackMessage *)readOrCreateFeedbackMessageByFilename:(NSString *)filename;

@end

#endif /* CR_FeedbackStorage_Internal_h */
