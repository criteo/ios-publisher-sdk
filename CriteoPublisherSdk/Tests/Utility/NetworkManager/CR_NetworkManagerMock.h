//
//  CR_NetworkManagerMock.h
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

#import "CR_NetworkManager.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString *const CR_NetworkManagerMockDefaultPostJsonResponse;

@interface CR_NetworkManagerMock : CR_NetworkManager

/** Default YES */
@property(nonatomic, assign, getter=isRespondingToPost) BOOL respondingToPost;
@property(nonatomic, strong, nullable) NSPredicate *postFilterUrl;
@property(nonatomic, strong, nullable) NSData *postResponseData;
@property(nonatomic, strong, nullable) NSError *postResponseError;
@property(nonatomic, strong, nullable) NSDictionary *lastPostBody;
@property(nonatomic, assign, readonly) NSUInteger numberOfPostCall;

@property(nonatomic, assign, getter=isRespondingToGet) BOOL respondingToGet;
@property(nonatomic, strong, nullable) NSData *getResponseData;
@property(nonatomic, strong, nullable) NSError *getResponseError;
@property(nonatomic, strong, nullable) NSURL *lastGetUrl;
@property(nonatomic, assign, readonly) NSUInteger numberOfGetCall;

- (instancetype)init NS_AVAILABLE_IOS(5_0);

@end

NS_ASSUME_NONNULL_END
