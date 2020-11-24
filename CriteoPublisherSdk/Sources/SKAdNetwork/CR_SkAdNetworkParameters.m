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

@implementation CR_SKAdNetworkParameters

#pragma mark - Lifecycle

/* TODO EE-1255
- (instancetype)initWithDict:(NSDictionary *)dict {
  return [self initWithNetworkId:...]
}
*/

- (instancetype)initWithNetworkId:(NSString *)networkId
                          version:(NSString *)version
                       campaignId:(NSNumber *)campaignId
                     iTunesItemId:(NSNumber *)iTunesItemId
                            nonce:(NSUUID *)nonce
                        timestamp:(NSNumber *)timestamp
                      sourceAppId:(NSNumber *)sourceAppId
                        signature:(NSString *)signature {
  self = [super init];
  if (self) {
    self.networkId = networkId;
    self.version = version;
    self.campaignId = campaignId;
    self.iTunesItemId = iTunesItemId;
    self.nonce = nonce;
    self.timestamp = timestamp;
    self.sourceAppId = sourceAppId;
    self.signature = signature;
  }

  return self;
}

#pragma mark - Load Product

- (NSDictionary *)toLoadProductParameters API_AVAILABLE(ios(14.0)) {
  return @{
    SKStoreProductParameterAdNetworkVersion : self.version,
    SKStoreProductParameterAdNetworkIdentifier : self.networkId,
    SKStoreProductParameterAdNetworkCampaignIdentifier : self.campaignId,
    SKStoreProductParameterITunesItemIdentifier : self.iTunesItemId,
    SKStoreProductParameterAdNetworkNonce : self.nonce,
    SKStoreProductParameterAdNetworkSourceAppStoreIdentifier : self.sourceAppId,
    SKStoreProductParameterAdNetworkTimestamp : self.timestamp,
    SKStoreProductParameterAdNetworkAttributionSignature : self.signature,
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
    copy.nonce = self.nonce;
    copy.timestamp = self.timestamp;
    copy.sourceAppId = self.sourceAppId;
    copy.signature = self.signature;
  }

  return copy;
}

@end
