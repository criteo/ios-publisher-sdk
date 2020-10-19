//
//  CR_FeedbackStorage+MessageUpdating.h
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
#import "CR_FeedbackStorage.h"
#import "CR_CdbBid.h"

@interface CR_FeedbackStorage (MessageUpdating)

- (void)setCdbStartForImpressionId:(NSString *)impressionId
                         profileId:(NSNumber *)profileId
                    requestGroupId:(NSString *)requestGroupId;

- (void)setCdbEndForImpressionId:(NSString *)impressionId zoneId:(NSNumber *)zoneId;

- (void)setCacheBidUsedForImpressionId:(NSString *)impressionId;

- (void)setCdbEndAndExpiredForImpressionId:(NSString *)impressionId;

- (void)setElapsedForImpressionId:(NSString *)impressionId;

- (void)setExpiredForImpressionId:(NSString *)impressionId;

- (void)setTimeoutAndExpiredForImpressionId:(NSString *)impressionId;

@end
