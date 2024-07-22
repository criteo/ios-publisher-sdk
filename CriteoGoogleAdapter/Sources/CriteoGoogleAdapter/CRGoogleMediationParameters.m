//
//  CRGoogleMediationParameters.m
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

#import "CRGoogleMediationParameters.h"
@import GoogleMobileAds;

static NSString *const criteoGoogleMediationPublisherIdKey = @"cpId";
static NSString *const criteoGoogleMediationAdUnitIdKey = @"adUnitId";
static NSString *const criteoGoogleMediationStoreIdKey = @"storeId";
static NSString *const criteoGoogleMediationInventoryGroupIdKey = @"inventoryGroupId";

static void setJSONParsingError(NSError **error) {
  if (error != nil) {
    *error = [NSError errorWithDomain:GADErrorDomain code:GADErrorInvalidArgument userInfo:nil];
  }
}

static NSString *nonEmptyStringFromObj(id obj) {
  if (obj == nil || ![obj isKindOfClass:[NSString class]]) {
    return nil;
  }
  NSString *str = (NSString *)obj;
  if (str.length == 0) {
    return nil;
  }
  return str;
}

@implementation CRGoogleMediationParameters

- (id)initWithPublisherId:(NSString *)publisherId
         inventoryGroupId:(NSString *)inventoryGroupId
                  storeId:(NSString *)storeId
                 adUnitId:(NSString *)adUnitId {
  self = [super init];
  if (self == nil) {
    return nil;
  }
  _publisherId = [NSString stringWithString:publisherId];
  _adUnitId = [NSString stringWithString:adUnitId];
  _storeId = [NSString stringWithString:storeId];
  if (inventoryGroupId != nil) {
    _inventoryGroupId = [NSString stringWithString:inventoryGroupId];
  }
  return self;
}

// Create the object with a string such as {"cpId":"B-056946", "adUnitID":
// "/140800857/Endeavour_320x50"}
+ (nullable CRGoogleMediationParameters *)parametersFromJSONString:(NSString *)jsonString
                                                             error:(NSError **)error {
  NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
  if (jsonString == nil || data == nil) {
    setJSONParsingError(error);
    return nil;
  }
  NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data
                                                           options:kNilOptions
                                                             error:nil];
  if (jsonDict == nil) {
    setJSONParsingError(error);
    return nil;
  }
  NSString *pubId = nonEmptyStringFromObj(jsonDict[criteoGoogleMediationPublisherIdKey]);
  NSString *adId = nonEmptyStringFromObj(jsonDict[criteoGoogleMediationAdUnitIdKey]);
  NSString *storeId = nonEmptyStringFromObj(jsonDict[criteoGoogleMediationStoreIdKey]);
  NSString *inventoryGroupId =
      nonEmptyStringFromObj(jsonDict[criteoGoogleMediationInventoryGroupIdKey]);
  if (pubId == nil || adId == nil) {
    setJSONParsingError(error);
    return nil;
  }
  if (error != nil) {
    *error = nil;
  }
  return [[CRGoogleMediationParameters alloc] initWithPublisherId:pubId
                                                 inventoryGroupId:inventoryGroupId
                                                          storeId:storeId
                                                         adUnitId:adId];
}
@end
