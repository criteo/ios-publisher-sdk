//
//  CR_CdbResponse.h
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

#ifndef CdbResponse_h
#define CdbResponse_h

#import <Foundation/Foundation.h>
#import "CR_CdbBid.h"

NS_ASSUME_NONNULL_BEGIN

@interface CR_CdbResponse : NSObject

@property(copy, nonatomic) NSArray<CR_CdbBid *> *cdbBids;
@property(assign, nonatomic) NSUInteger timeToNextCall;
/** `consentGiven` is nil if not provided in response, use boolValue otherwise */
@property(strong, nonatomic) NSNumber *consentGiven;

/**
 * Helper function to convert NSData returned from a network call
 * to a CR_CdbResponse object.
 *
 * @return a CR_CdbResponse or nil if the parameters are nil.
 */
+ (nullable CR_CdbResponse *)responseWithData:(nullable NSData *)data
                                   receivedAt:(nullable NSDate *)receivedAt;

@end

NS_ASSUME_NONNULL_END

#endif /* CdbResponse_h */
