//
//  CR_BidRequestSerializer.m
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

#import "CR_ApiQueryKeys.h"
#import "CR_BidRequestSerializer.h"
#import "CR_CdbRequest.h"
#import "CR_Config.h"
#import "CR_DataProtectionConsent.h"
#import "CR_DeviceInfo.h"
#import "CR_GdprSerializer.h"
#import "CR_IntegrationRegistry.h"

@interface CR_BidRequestSerializer ()

@property(strong, nonatomic, readonly) CR_GdprSerializer *gdprSerializer;

@end

@implementation CR_BidRequestSerializer

#pragma mark - Life cycle

- (instancetype)initWithGdprSerializer:(CR_GdprSerializer *)gdprSerializer {
  if (self = [super init]) {
    _gdprSerializer = gdprSerializer;
  }
  return self;
}

#pragma mark - Public

- (NSURL *)urlWithConfig:(CR_Config *)config {
  NSString *urlString = [NSString stringWithFormat:@"%@/%@", config.cdbUrl, config.path];
  NSURL *url = [NSURL URLWithString:urlString];
  return url;
}

- (NSDictionary *)bodyWithCdbRequest:(CR_CdbRequest *)cdbRequest
                             consent:(CR_DataProtectionConsent *)consent
                              config:(CR_Config *)config
                          deviceInfo:(CR_DeviceInfo *)deviceInfo {
  NSMutableDictionary *postBody = [NSMutableDictionary new];
  postBody[CR_ApiQueryKeys.sdkVersion] = config.sdkVersion;
  postBody[CR_ApiQueryKeys.profileId] = cdbRequest.profileId;
  postBody[CR_ApiQueryKeys.id] = cdbRequest.requestGroupId;
  postBody[CR_ApiQueryKeys.publisher] = [self publisherWithConfig:config];
  postBody[CR_ApiQueryKeys.gdpr] = [self.gdprSerializer dictionaryForGdpr:consent.gdpr];
  postBody[CR_ApiQueryKeys.bidSlots] = [self slotsWithCdbRequest:cdbRequest];
  postBody[CR_ApiQueryKeys.user] = [self userWithConsent:consent
                                                  config:config
                                              deviceInfo:deviceInfo];
  return postBody;
}

#pragma mark - Private

- (NSDictionary *)userWithConsent:(CR_DataProtectionConsent *)consent
                           config:(CR_Config *)config
                       deviceInfo:(CR_DeviceInfo *)deviceInfo {
  NSMutableDictionary *userDict = [NSMutableDictionary new];
  userDict[CR_ApiQueryKeys.deviceModel] = config.deviceModel;
  userDict[CR_ApiQueryKeys.deviceOs] = config.deviceOs;
  userDict[CR_ApiQueryKeys.deviceId] = deviceInfo.deviceId;
  userDict[CR_ApiQueryKeys.userAgent] = deviceInfo.userAgent;
  userDict[CR_ApiQueryKeys.deviceIdType] = CR_ApiQueryKeys.deviceIdValue;

  if (consent.usPrivacyIabConsentString.length > 0) {
    userDict[CR_ApiQueryKeys.uspIab] = consent.usPrivacyIabConsentString;
  }
  if (consent.usPrivacyCriteoState == CR_CcpaCriteoStateOptIn) {
    userDict[CR_ApiQueryKeys.uspCriteoOptout] = @NO;
  } else if (consent.usPrivacyCriteoState == CR_CcpaCriteoStateOptOut) {
    userDict[CR_ApiQueryKeys.uspCriteoOptout] = @YES;
  }  // else if unknown we add nothing.

  if (consent.mopubConsent.length > 0) {
    userDict[CR_ApiQueryKeys.mopubConsent] = consent.mopubConsent;
  }

  return userDict;
}

- (NSDictionary *)publisherWithConfig:(CR_Config *)config {
  NSMutableDictionary *publisher = [NSMutableDictionary new];
  publisher[CR_ApiQueryKeys.bundleId] = config.appId;
  publisher[CR_ApiQueryKeys.cpId] = config.criteoPublisherId;
  return publisher;
}

- (NSArray *)slotsWithCdbRequest:(CR_CdbRequest *)cdbRequest {
  NSMutableArray *slots = [NSMutableArray new];
  for (CR_CacheAdUnit *adUnit in cdbRequest.adUnits) {
    NSMutableDictionary *slotDict = [NSMutableDictionary new];
    slotDict[CR_ApiQueryKeys.bidSlotsPlacementId] = adUnit.adUnitId;
    slotDict[CR_ApiQueryKeys.bidSlotsSizes] = @[ adUnit.cdbSize ];
    NSString *impressionId = [cdbRequest impressionIdForAdUnit:adUnit];
    if (impressionId) {
      slotDict[CR_ApiQueryKeys.impId] = impressionId;
    }
    if (adUnit.adUnitType == CRAdUnitTypeNative) {
      slotDict[CR_ApiQueryKeys.bidSlotsIsNative] = @(YES);
    } else if (adUnit.adUnitType == CRAdUnitTypeInterstitial) {
      slotDict[CR_ApiQueryKeys.bidSlotsIsInterstitial] = @(YES);
    }
    [slots addObject:slotDict];
  }
  return slots;
}

+ (NSDictionary<NSString *, id> *)mergeToNestedStructure:
    (NSArray<NSDictionary<NSString *, id> *> *)flattenDictionaries {
  NSMutableDictionary<NSString *, id> *nestedStructure = NSMutableDictionary.new;

  // Use an array instead of a set to use the ref equality instead of the object equality
  NSMutableArray<NSMutableDictionary<NSString *, id> *> *subNodes = NSMutableArray.new;

  for (NSDictionary<NSString *, id> *flattenDictionary in flattenDictionaries) {
    for (NSString *path in flattenDictionary) {
      NSArray<NSString *> *pathParts = [path componentsSeparatedByString:@"."];
      if ([CR_BidRequestSerializer isPathPartsNoValid:pathParts]) {
        continue;
      }

      NSMutableDictionary<NSString *, id> *node = nestedStructure;

      // Go or create nested structure until last path part
      for (NSUInteger i = 0; i < pathParts.count - 1; ++i) {
        NSString *pathPart = pathParts[i];

        id nestedValue = node[pathPart];
        if (nestedValue != nil) {
          if ([subNodes containsObject:nestedValue]) {
            // It's a sub node, go deeper
            node = nestedValue;
          } else {
            // It's a leaf, abort
            break;
          }
        } else {
          // Create a new node and go deeper
          NSMutableDictionary<NSString *, id> *newNode = NSMutableDictionary.new;
          [subNodes addObject:newNode];
          node[pathPart] = newNode;
          node = newNode;
        }
      }

      NSString *lastPathPart = pathParts[pathParts.count - 1];
      if (node[lastPathPart] == nil) {
        // If value is already there, abort, else save it
        node[lastPathPart] = flattenDictionary[path];
      }
    }
  }

  return nestedStructure;
}

+ (BOOL)isPathPartsNoValid:(NSArray<NSString *> *)pathParts {
  for (NSString *pathPart in pathParts) {
    if (pathPart.length == 0) {
      return YES;
    }
  }
  return NO;
}

@end
