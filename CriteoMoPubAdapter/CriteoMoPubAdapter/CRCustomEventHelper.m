//
//  CRCustomEventHelper.m
//  CriteoMoPubAdapter
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

#import "CRCustomEventHelper.h"
#import "MPNativeAdError.h"

NSString * const kCRCustomEventHelperCpId = @"cpId";
NSString * const kCRCustomEventHelperAdUnitId = @"adUnitId";

@implementation CRCustomEventHelper

+ (BOOL)checkValidInfo:(NSDictionary *)info {
    return [self checkValidInfo:info
                      withError:nil];
}

+ (BOOL)checkValidInfo:(NSDictionary *)eventInfo
             withError:(NSError **)error {
    NSArray<NSString *> *expectedKeys = @[
        kCRCustomEventHelperCpId,
        kCRCustomEventHelperAdUnitId
    ];
    NSMutableString *errorMsg = [[NSMutableString alloc] init];
    BOOL isValid = YES;
    for (NSString *key in expectedKeys) {
        NSString *value = eventInfo[key];
        if (![value isKindOfClass:NSString.class] ||
            (value.length == 0)) {
            isValid = NO;
            NSString *str = [[NSString alloc] initWithFormat:
                             @"The Criteo '%@' key is missing or invalid. ",
                             key];
            [errorMsg appendString:str];
        }
    }
    if (!isValid && (error != nil)) {
        [errorMsg appendString:@"No ad request sent. "
                                "Ensure this key is valid on the MoPub dashboard."];
        *error = MPNativeAdNSErrorForInvalidAdServerResponse(errorMsg);
    }
    return isValid;
}

@end
