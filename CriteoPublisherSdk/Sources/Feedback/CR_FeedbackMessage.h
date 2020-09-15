//
//  CR_FeedbackMessage.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CR_FeedbackMessage : NSObject <NSSecureCoding, NSCopying>

@property(strong, nonatomic) NSNumber *profileId;
@property(strong, nonatomic) NSString *impressionId;
@property(strong, nonatomic) NSString *requestGroupId;
@property(strong, nonatomic) NSNumber *zoneId;
@property(strong, nonatomic) NSNumber *cdbCallStartTimestamp;
@property(strong, nonatomic) NSNumber *cdbCallEndTimestamp;
@property(strong, nonatomic) NSNumber *elapsedTimestamp;
@property(assign, nonatomic, getter=isTimeout) BOOL timeout;
@property(assign, nonatomic, getter=isExpired) BOOL expired;
@property(assign, nonatomic) BOOL cachedBidUsed;
@property(assign, nonatomic, getter=isReadyToSend, readonly) BOOL readyToSend;

@end

NS_ASSUME_NONNULL_END
