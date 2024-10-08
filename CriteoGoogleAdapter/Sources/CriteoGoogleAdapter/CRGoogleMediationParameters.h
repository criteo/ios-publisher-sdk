//
//  CRGoogleMediationParameters.h
//  CriteoGoogleAdapter
//
//  Copyright © 2018-2022 Criteo. All rights reserved.
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

@interface CRGoogleMediationParameters : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (id)initWithPublisherId:(NSString *)publisherId
         inventoryGroupId:(NSString *)inventoryGroupId
                  storeId:(NSString *)storeId
                 adUnitId:(NSString *)adUnitId;
+ (nullable CRGoogleMediationParameters *)parametersFromJSONString:(NSString *)jsonString
                                                             error:(NSError **)outError;

@property(copy, readonly) NSString *publisherId;
@property(copy, readonly) NSString *adUnitId;
@property(copy, readonly) NSString *storeId;
@property(copy, nullable, readonly) NSString *inventoryGroupId;

@end

NS_ASSUME_NONNULL_END
