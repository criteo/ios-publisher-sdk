//
//  CR_SKAdNetworkHandler.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2023 Criteo. All rights reserved.
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

#import "CR_SKAdNetworkHandler.h"
#import <StoreKit/SKAdImpression.h>
#import <StoreKit/SKAdNetwork.h>
#import "CR_Logging.h"
#import "CR_SKAdNetworkFidelityParameter.h"

#define CR_SKAD_FIDELITY_VIEW_THROUGH_AD 1
#define CR_SKAD_FIDELITY_STORE_KIT_AD 0

API_AVAILABLE(ios(14.5))
@interface CR_SKAdNetworkHandler ()

@property(nonatomic, strong) CR_SKAdNetworkParameters *skAdNetworkParameters;
@property(nonatomic, strong) SKAdImpression *skadImpression;

@end

@implementation CR_SKAdNetworkHandler

- (instancetype)initWithParameters:(CR_SKAdNetworkParameters *)skAdNetworkParameters {
  if (self = [super init]) {
    _skAdNetworkParameters = skAdNetworkParameters;
  }
  return self;
}

- (void)startSKAdImpression {
  CR_SKAdNetworkFidelityParameter *fidelityParameter =
      [_skAdNetworkParameters.fidelities firstObject];
  /// Start the impression only for view through ad type which has fidelity type set to 1
  if (fidelityParameter == NULL ||
      fidelityParameter.fidelity.intValue == CR_SKAD_FIDELITY_STORE_KIT_AD) {
    return;
  }
  /// Exit the flow if the skad parameters is null or the impression is already started
  if (_skAdNetworkParameters == NULL || _skadImpression != NULL) {
    return;
  }

  _skadImpression = [self skadImpressionForParameters:_skAdNetworkParameters
                                        fidelityParam:fidelityParameter];
  [SKAdNetwork startImpression:_skadImpression
             completionHandler:^(NSError *_Nullable error) {
               if (error) {
                 CRLogError(@"SKAdNetwork", @"Start impression failed: %@", error);
               }
             }];
}

- (void)endSKAdImpression {
  if (_skadImpression) {
    [SKAdNetwork endImpression:_skadImpression
             completionHandler:^(NSError *_Nullable error) {
               if (error) {
                 CRLogError(@"SKAdNetwork", @"End impression failed: %@", error);
               }
             }];
    _skadImpression = NULL;
  }
}

- (SKAdImpression *)skadImpressionForParameters:(CR_SKAdNetworkParameters *)parameters
                                  fidelityParam:(CR_SKAdNetworkFidelityParameter *)fidelity
    API_AVAILABLE(ios(14.5)) {
  if (@available(iOS 16.0, *)) {
    return [[SKAdImpression alloc] initWithSourceAppStoreItemIdentifier:parameters.sourceAppId
                                       advertisedAppStoreItemIdentifier:parameters.iTunesItemId
                                                    adNetworkIdentifier:parameters.networkId
                                                   adCampaignIdentifier:parameters.campaignId
                                                 adImpressionIdentifier:fidelity.nonce.UUIDString
                                                              timestamp:fidelity.timestamp
                                                              signature:fidelity.signature
                                                                version:parameters.version];
  } else {
    SKAdImpression *impression = [[SKAdImpression alloc] init];
    impression.sourceAppStoreItemIdentifier = parameters.sourceAppId;
    impression.sourceAppStoreItemIdentifier = parameters.iTunesItemId;
    impression.adNetworkIdentifier = parameters.networkId;
    impression.adCampaignIdentifier = parameters.campaignId;
    impression.adImpressionIdentifier = fidelity.nonce.UUIDString;
    impression.timestamp = fidelity.timestamp;
    impression.signature = fidelity.signature;
    impression.version = parameters.version;

    return impression;
  }
}
@end
