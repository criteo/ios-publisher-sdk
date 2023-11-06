//
//  CR_SKAdNetworkParameters.m
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

#import "CR_SKAdNetworkParameters.h"

#import <StoreKit/StoreKit.h>
#import "CR_Logging.h"
#import "NSString+Criteo.h"
#import "CR_SKAdNetworkFidelityParameter.h"

@implementation CR_SKAdNetworkParameters

#pragma mark - Lifecycle

- (instancetype)initWithDict:(NSDictionary *)dict {
  return [self initWithNetworkId:[NSString cr_nonEmptyStringWithStringOrNil:dict[@"network"]]
                         version:[NSString cr_nonEmptyStringWithStringOrNil:dict[@"version"]]
                      campaignId:@([dict[@"campaign"] intValue])
                    iTunesItemId:@([dict[@"itunesItem"] intValue])
                     sourceAppId:@([dict[@"sourceApp"] intValue])
                      fidelities:[self fidelitiesFromList:dict[@"fidelities"]]];
}

- (instancetype)initWithNetworkId:(NSString *)networkId
                          version:(NSString *)version
                       campaignId:(NSNumber *)campaignId
                     iTunesItemId:(NSNumber *)iTunesItemId
                      sourceAppId:(NSNumber *)sourceAppId
                       fidelities:(NSArray *)fidelities {
  if (networkId == nil || version == nil || campaignId == nil || campaignId.intValue == 0 ||
      iTunesItemId == nil || iTunesItemId.intValue == 0 || sourceAppId == nil || fidelities == nil) {
    CRLogError(@"SKAdNetwork", @"Unsupported payload format");
    return nil;
  }
  self = [super init];
  if (self) {
    self.networkId = networkId;
    self.version = version;
    self.campaignId = campaignId;
    self.iTunesItemId = iTunesItemId;
    self.sourceAppId = sourceAppId;
    self.fidelities = fidelities;
  }

  return self;
}

#pragma mark - Load Product

- (NSDictionary *)toLoadProductParameters API_AVAILABLE(ios(14.0)) {
    CR_SKAdNetworkFidelityParameter *fidelityParam = [self.fidelities firstObject];
  return @{
    SKStoreProductParameterAdNetworkVersion : self.version,
    SKStoreProductParameterAdNetworkIdentifier : self.networkId,
    SKStoreProductParameterAdNetworkCampaignIdentifier : self.campaignId,
    SKStoreProductParameterITunesItemIdentifier : self.iTunesItemId,
    SKStoreProductParameterAdNetworkNonce : fidelityParam.nonce,
    SKStoreProductParameterAdNetworkSourceAppStoreIdentifier : self.sourceAppId,
    SKStoreProductParameterAdNetworkTimestamp : fidelityParam.timestamp,
    SKStoreProductParameterAdNetworkAttributionSignature : fidelityParam.signature,
  };
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
  CR_SKAdNetworkParameters *copy =
      (CR_SKAdNetworkParameters *)[[[self class] allocWithZone:zone] init];

  if (copy != nil) {
    copy.networkId = self.networkId;
    copy.version = self.version;
    copy.campaignId = self.campaignId;
    copy.iTunesItemId = self.iTunesItemId;
    copy.sourceAppId = self.sourceAppId;
    copy.fidelities = self.fidelities;
  }

  return copy;
}

#pragma mark - Fidelity utils
- (NSArray *)fidelitiesFromList:(NSArray *)list {
  NSMutableArray *fidelities = [NSMutableArray new];
  for (id item in list) {
    CR_SKAdNetworkFidelityParameter *fidelity =
        [[CR_SKAdNetworkFidelityParameter alloc] initWithDict:item];
    if (fidelity) {
      [fidelities addObject:fidelity];
    }
  }
  return fidelities;
}

@end
